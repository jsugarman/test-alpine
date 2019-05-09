FROM ruby:2.6.3-alpine3.9

# install regular stuff
# and extra dev libs required for nokogiri, at least
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  nodejs

# only needed for sqllite3
RUN apk add sqlite-dev

# tidy up
RUN rm -rf /var/cache/apk/*

WORKDIR /app
RUN mkdir -p /app/tmp

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

# install JS package managers
RUN apk add yarn
RUN RAILS_ENV=production bundle exec rake assets:precompile

# ENTRYPOINT ["rails", "server"]
EXPOSE 3000
CMD ["rails", "server", "-e", "production", "--port", "3000", "--binding", "0.0.0.0"]

