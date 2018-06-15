#!/bin/sh

bundle install >/dev/null
bundle exec rubocop --color "$@"
