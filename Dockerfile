FROM ruby:2.4.9-alpine AS GEMS

RUN apk add --update --no-cache \
  build-base=0.5 \
  postgresql-dev=12.7

COPY Gemfile Gemfile.lock /app/
RUN bundle install --jobs=3 --retry=3

FROM ruby:2.4.9-alpine AS CODE
RUN apk add --update --no-cache postgresql-client=12.7-r0
COPY --from=GEMS /usr/local/bundle/ /usr/local/bundle/

COPY ./ /app/

WORKDIR /app
