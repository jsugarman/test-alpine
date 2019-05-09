FROM ruby:2.6.3-alpine3.9

WORKDIR /app
RUN mkdir -p /app/tmp

# install dependencies
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle config --global without test:development
RUN gem install bundler -v 1.17.3
RUN bundle install

RUN bundle exec rake assets:precompile RAILS_ENV=production

ENTRYPOINT ["rails", "server", "-p", "3010"]
