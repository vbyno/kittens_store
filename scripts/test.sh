#!/bin/sh

set -e

bundle exec rake db:create db:test:prepare

bundle exec rspec spec
