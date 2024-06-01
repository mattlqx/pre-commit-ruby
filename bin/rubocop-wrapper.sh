#!/usr/bin/env sh

bundle install >/dev/null
bundle exec rubocop --force-exclusion --color "$@"
