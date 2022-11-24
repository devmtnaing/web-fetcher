FROM ruby:3.0

WORKDIR /app
COPY . /app

RUN bundle install
RUN chmod +x /app/fetch.rb

ENTRYPOINT [ "ruby", "fetch.rb" ]
