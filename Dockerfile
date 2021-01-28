FROM ruby:2.7.1
WORKDIR /app
COPY . .
RUN gem install bundler \
  && bundle install
ENTRYPOINT ["bundle", "exec", "jekyll", "serve", "--watch", "--force_polling", "--livereload", "--future"]
