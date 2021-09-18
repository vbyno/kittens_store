FROM ruby:2.4.9-alpine AS GEMS

RUN apk add --update --no-cache \
  build-base=0.5-r1 \
  postgresql-dev=12.8-r0

WORKDIR /app
COPY Gemfile* ./
RUN bundle install --jobs=3 --retry=3

FROM ruby:2.4.9-alpine AS CODE
RUN apk add --update --no-cache postgresql-client=12.8-r0
COPY --from=GEMS /usr/local/bundle/ /usr/local/bundle/
RUN mkdir /app
WORKDIR /app
COPY ./ ./
