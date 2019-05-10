FROM ruby:2.6.3-alpine3.9

# install regular stuff
# - extra libxml2-dev libxslt-dev required for nokogiri
# - postgresql-dev required for postgres
# - nodejs needed for ExecJS functionality
# - yarn needed for asset compilation
#
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev \
  nodejs \
  yarn

# tidy up
RUN rm -rf /var/cache/apk/*

WORKDIR /app
RUN mkdir -p /app/tmp

# Env vars need for asset precompilation but otherwise
# only needed if using plain docker build, docker run
#
ENV RAILS_ENV='production'
ENV RACK_ENV='production'

######################
# DEPENDENCIES START #
######################

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler -v 1.17.3

# remove test development gems from default bundle install
RUN bundle config --global without test:development

# nokogiri install problems
# https://github.com/gliderlabs/docker-alpine/issues/53
#
# Use libxml2-dev, libxslt-dev packages, installed above, for building nokogiri
RUN bundle config build.nokogiri --use-system-libraries

RUN bundle install
####################
# DEPENDENCIES END #
####################

# copy app contents from host to container
COPY . .

# compile assets (note production environment set above)
RUN bundle exec rake assets:precompile

# Below only need if using plain docker build, docker run
# ,not docker compose.
# In such instances you can:
# build: docker build -f Dockerfile -t rails-alpine-test:latest .
# run: docker run -it -p 5000:5000 rails-alpine-test:latest
# browser: localhost:5000
#
# EXPOSE 5000
# CMD ["rails", "server", "-e", "production", "--port", "5000", "--binding", "0.0.0.0"]
