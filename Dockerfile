FROM alpine:3.7

ENV BUILD_PACKAGES bash curl curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-irb ruby-json libffi-dev zlib-dev ruby-bigdecimal
ENV TERM=linux
ENV PS1 "\n\n>> ruby \W \$ "

ENV REPOSITORY_FILE=./config/repositories.yml \
    REPOSITORY_URL=https://raw.githubusercontent.com/sul-dlss/arclight/master/spec/fixtures/config/repositories.yml \
    REPOSITORY_ID=sample \
    SOLR_URL=http://127.0.0.1:8983/solr/arclight

RUN apk --no-cache add $BUILD_PACKAGES $RUBY_PACKAGES && \
    echo 'gem: --no-document' > /etc/gemrc && gem install bundler && \
    bundle config --global silence_root_warning 1

RUN mkdir -p /usr/app/config
WORKDIR /usr/app

COPY Gemfile* /usr/app/
RUN bundle install && wget -O $REPOSITORY_FILE $REPOSITORY_URL

COPY . /usr/app
CMD ["bundle", "exec", "rake", "-T"]
