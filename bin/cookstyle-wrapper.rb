#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require_relative 'common'

# Check each changed file for a spec directory in its heirarchy
fix = ''
Array.new(ARGV).each do |arg|
  next unless arg == '--fix'

  fix = '-a'
  ARGV.delete('--fix')
  break
end

# Exit early if there are no paths to lint
success = true
exit(success) if changed_cookbooks(bump_check: false).compact.empty?

# Install cookstyle and drop args that are paths
system('bundle install >/dev/null') || exit(false)
system("bundle exec cookstyle --color #{fix} #{changed_cookbooks(bump_check: false).map(&:first).join(' ')}")
exit($CHILD_STATUS.exitstatus)
