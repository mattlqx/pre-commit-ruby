#!/bin/sh

bundle install >/dev/null
bundle exec rubocop --force-exclusion --color "$@"
