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
  test_dir = spec_walk(file)
  test_dirs << test_dir if test_dir
end

# Remove duplicates and run rspec in alphabetical order against directories
test_dirs.uniq!
test_dirs.sort!
root = FileUtils.pwd
test_dirs.each do |dir|
  FileUtils.cd(dir)
  puts "=========== Running rspec in #{dir}"
  # Fail fast, we don't want to have to search for the failures
  (system('bundle install >/dev/null') && system('bundle exec rspec --format doc --force-color')) || exit(false)
  FileUtils.cd(root)
end
