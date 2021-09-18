#!/bin/sh

set -e

bundle exec rake db:create db:migrate db:seed;

bundle exec rackup --port "$PORT" --host "$HOST"
