FROM ruby:2.6.3-alpine3.9
MAINTAINER Joel Sugarman <joelsugarman@yahoo.co.uk>

# fail early and print commands
RUN set -ex

# Add an non-root "system" user for further setup
# RUN addgroup --system appgroup
# RUN adduser --system appuser -G appgroup

# Additional packages/libraries
# - install regular stuff build-base
# - install libxml2-dev libxslt-dev required for nokogiri
# - install postgresql-dev required for postgres
# - install nodejs needed for ExecJS functionality
# - install yarn needed for asset compilation
#
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev \
  nodejs \
  yarn

# tidy up installation
RUN rm -rf /var/cache/apk/*

# Add a non-root user for app ownership
RUN addgroup \
    --gid 1000 \
    --system \
    appgroup

RUN adduser \
    --uid 1000 \
    --system appuser \
    -G appgroup

# grant appgroup privileges on working_dir

# list group memberships
RUN cat /etc/group | grep appuser

# list user details
RUN cat /etc/passwd | grep appuser

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN mkdir -p /usr/src/app/tmp
RUN ls -la /usr/src

# Env vars needed for asset precompilation but otherwise
# only needed if using plain docker build, docker run
# see environment: key-values in docker-compose.yml
#
ENV RAILS_ENV='production'
ENV RACK_ENV='production'

######################
# DEPENDENCIES START #
######################
# NOTE: all COPY commands set file permissions to root
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# change to the added user
USER appuser
RUN gem install bundler -v 1.17.3
RUN bundle config
RUN echo $BUNDLE_APP_CONFIG

# remove test development gems from default bundle install
RUN bundle config --global without test:development

# nokogiri install problems
# https://github.com/gliderlabs/docker-alpine/issues/53
#
# Use libxml2-dev, libxslt-dev packages, installed above, for building nokogiri
RUN bundle config build.nokogiri --use-system-libraries

RUN bundle install
RUN ls -la ${BUNDLE_APP_CONFIG}

####################
# DEPENDENCIES END #
####################

# copy app contents from host to container (owner will be root)
COPY . .

# take ownership of all app files
USER root
RUN ls -la /usr/src/app
RUN chown -R appuser:appgroup /usr/src/
RUN ls -la /usr/src/app

# compile assets (note production environment set above)
USER appuser
RUN bundle exec rake assets:precompile
RUN ls -la /usr/src/app/public/assets

# Below only need if using plain docker build, docker run
# ,not docker compose.
# In such instances you can:
# build: docker build -f Dockerfile -t rails-alpine-test:latest .
# run: docker run -it -p 5000:5000 rails-alpine-test:latest
# browser: localhost:5000
#
# EXPOSE 5000
# CMD ["rails", "server", "-e", "production", "--port", "5000", "--binding", "0.0.0.0"]
