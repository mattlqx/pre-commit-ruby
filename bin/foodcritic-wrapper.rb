#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

def spec_walk(path)
  dir = File.dirname(path)
  if Dir.exist?(File.join(dir, 'spec'))
    dir
  elsif ['.', '/'].include?(dir)
    false
  else
    spec_walk(dir)
  end
end

# Check each changed file for a spec directory in its heirarchy
test_dirs = []
ARGV.each do |file|
  next unless File.exist?(file)
  test_dir = spec_walk(file)
  test_dirs << test_dir if test_dir
end

# Exit early if there are no paths to lint
exit(true) if test_dirs.empty?

# Install foodcritic and drop args that are paths
system('bundle install >/dev/null') || exit(false)
fc_args = ARGV.reject { |f| File.exist?(f) }

# Remove duplicates and run rspec in alphabetical order against directories
test_dirs.uniq!
test_dirs.sort!
test_dirs.each do |dir|
  puts "=========== Running foodcritic on #{dir}"
  # Fail fast, we don't want to have to search for the failures
  system("bundle exec foodcritic #{fc_args.join(' ')} #{dir}") || exit(false)
end
