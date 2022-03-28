FROM ruby:3.0.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD . /app
RUN gem install bundler
RUN bundle install

EXPOSE 3000
CMD puma -C config/puma.rb
