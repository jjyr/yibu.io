FROM rails:5

# update bundler version
RUN gem install bundler

# install gems
WORKDIR /app
ADD Gemfile /app
ADD Gemfile.lock /app
RUN bundle install

# install nodejs
RUN apt-get update && apt-get install -y apt-transport-https && apt-get install -y --no-install-recommends apt-utils
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# install yarn
RUN npm install -g yarn
ENV PATH="${PATH}:`npm bin`"
RUN ln -s `which nodejs` /usr/local/bin/node

# install yarn packages
ADD bin /app/bin
ADD package.json /app
ADD yarn.lock /app
RUN bin/yarn

# add app directory
ADD . /app

# link awesome fonts
RUN ln -s /app/node_modules/font-awesome/fonts /app/public/fonts

ENV RAILS_ENV production

RUN bin/rake assets:precompile

# mark public directory as volume
VOLUME /app/public
# fix soft link in docker share volume issue
RUN rm public/fonts && cp -r ./node_modules/font-awesome/fonts public/fonts

# puma config
ENV RAILS_MAX_THREADS 5
ENV WEB_CONCURRENCY 1
