#!/bin/sh

set -e

PORT=${PORT:-3000}
HOST=${HOST:-"0.0.0.0"}
RACK_ENV=${RACK_ENV="development"}

bundle exec rake db:create db:migrate db:seed

bundle exec rackup --port "$PORT" --host "$HOST"
