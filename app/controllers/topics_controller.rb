class TopicsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  before_action :set_topic_by_user, only: [:edit, :update, :destroy]
  before_action :set_topic, only: [:show, :up_vote, :down_vote, :unvote]

  # GET /topics
  # GET /topics.json
  def index
    @tag = params[:id] ? Tag.find(params[:id]) : nil
    @topics = Topic.by_tag(@tag).includes(:tag).sort_by_score.page(params[:page]).per(30)
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @comments = @topic.root_comment&.subtree || []
  end

  # GET /topics/new
  def new
    @topic = current_user.topics.new tag_id: params[:tag_id]
  end

  # GET /topics/1/edit
  def edit
    @topic = set_topic_by_user
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = current_user.topics.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.html {redirect_to @topic, notice: '成功提交话题'}
        format.json {render :show, status: :created, location: @topic}
      else
        format.html {render :new}
        format.json {render json: @topic.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html {redirect_to @topic, notice: 'Topic was successfully updated.'}
        format.json {render :show, status: :ok, location: @topic}
      else
        format.html {render :edit}
        format.json {render json: @topic.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.destroy
    respond_to do |format|
      format.html {redirect_to topics_url, notice: 'Topic was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  def up_vote
    @vote = current_user.up_vote(@topic)
    respond_to do |format|
      format.js {render 'update_vote'}
      format.html
    end
  end

  def down_vote
    @vote = current_user.down_vote(@topic)
    respond_to do |format|
      format.js {render 'update_vote'}
      format.html
    end
  end

  def unvote
    @vote = current_user.unvote(@topic)
    respond_to do |format|
      format.js {render 'update_vote'}
      format.html
    end
  end

  # POST /topics/preview
  def preview
    content = params[:content] || ''
    respond_to do |format|
      format.json {render 'preview', locals: {content: content}}
    end
  end

  private
  def set_topic_by_user
    @topic = current_user.topics.find(params[:id])
  end

  def set_topic
    @topic = Topic.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def topic_params
    params.require(:topic).permit(:title, :content, :format, :tag_id)
  end
end
