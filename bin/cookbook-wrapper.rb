#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'

def metadata_walk(path)
  dir = File.directory?(path) ? path : File.dirname(path)
  if File.exist?(File.join(dir, 'metadata.rb')) || File.exist?(File.join(dir, 'metadata.json'))
    [dir, File.exist?(File.join(dir, 'metadata.json')) ? 'json' : 'rb']
  elsif ['.', '/'].include?(dir)
    false
  else
    metadata_walk(File.dirname(dir))
  end
end

def bump_required?(file)
  %w[
    metadata.(rb|json)
    Berksfile
    Berksfile.lock
    Policyfile.rb
    Policyfile.lock.json
    recipes/.*
    attributes/.*
    libraries/.*
    files/.*
    templates/.*
  ].each do |regex|
    break true if file.match?("#{regex}$")
  end == true
end

def higher?(old_version, new_version)
  old_version = old_version.split('.')
  new_version.split('.').each_with_index do |n, idx|
    break true if n > old_version[idx]
  end == true
end

def file_from_git_history(branch, path)
  prefix = path.start_with?('/') ? '' : './'
  from_branch = IO.popen("git show origin/#{branch}:#{prefix}#{path}", err: :close, &:read)
  return from_branch unless from_branch == ''

  IO.popen("git show origin/master:#{prefix}#{path}", err: :close, &:read)
end

# Simple metadata.rb reader
class MetadataReader
  attr_reader :data
  attr_reader :raw

  def initialize(metadata, path)
    @data = {}
    @raw = metadata
    instance_eval(metadata, path)
  end

  def [](key)
    @data[key.to_sym]
  end

  def empty?
    @data.empty?
  end

  def method_missing(sym, *args, &_block) # rubocop:disable Metrics/AbcSize, Style/MethodMissingSuper, Style/MissingRespondToMissing, Metrics/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return @data[sym] if args.empty?

    if args.length > 1
      @data[sym] ||= []
      @data[sym] = [@data[sym]] unless @data[sym].is_a?(Array)
      @data[sym] << args
    elsif @data.key?(sym)
      @data[sym] = [@data[sym]] unless @data[sym].is_a?(Array)
      @data[sym] += args
    else
      @data[sym] = args.length == 1 ? args[0] : args
    end
  end
end

# Check each changed file for a metadata file in its heirarchy
success = true
autofix = false
changed_cookbooks = []
ARGV.each do |file|
  cookbook, type = metadata_walk(file)
  next if changed_cookbooks.map(&:first).include?(cookbook)

  changed_cookbooks << [cookbook, type] if bump_required?(file)
end

exit(success) if changed_cookbooks.empty?

IO.popen('git fetch origin') { |_f| true }
branch = IO.popen('git symbolic-ref --short HEAD', &:read).chomp
changed_cookbooks.each do |cb_data|
  cookbook = cb_data[0]
  type = cb_data[1]

  if type == 'rb'
    old_metadata = MetadataReader.new(file_from_git_history(branch, "#{cookbook}/metadata.rb"), "#{cookbook}/metadata.rb") # rubocop:disable Metrics/LineLength
    new_metadata = MetadataReader.new(IO.read("#{cookbook}/metadata.rb"), "#{cookbook}/metadata.rb")
  else
    old_metadata = JSON.parse(file_from_git_history(branch, "#{cookbook}/metadata.json")) rescue {} # rubocop:disable Style/RescueModifier, Metrics/LineLength
    new_metadata = JSON.parse(IO.read("#{cookbook}/metadata.json"))
  end

  if old_metadata.empty?
    puts "#{cookbook} does not have a metadata file in git history. Skipping."
  elsif new_metadata['version'] == old_metadata['version']
    puts "#{cookbook} has changed and has not been version bumped."
    success = false
    autofix = true
  elsif !higher?(old_metadata['version'], new_metadata['version'])
    puts "#{cookbook} version is not higher than in branch on origin. Please fix manually."
    success = false
    autofix = false
  end
  next unless autofix

  bumped_version = new_metadata['version'].split('.').map(&:to_i)
  bumped_version[-1] += 1
  bumped_version = bumped_version.join('.')
  puts "Auto-fixing #{cookbook} version to next patch-level. (#{bumped_version})"
  if type == 'rb'
    new_metadata_content = new_metadata.raw.sub(
      /^(\s+)*version(\s+)(['"])[0-9.]+['"](.*)$/, "\\1version\\2\\3#{bumped_version}\\3\\4"
    )
    IO.write("#{cookbook}/metadata.rb", new_metadata_content)
  else
    new_metadata['version'] = bumped_version
    IO.write("#{cookbook}/metadata.json", JSON.dump(new_metadata))
  end
end

exit(success)
