# frozen_string_literal: true

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

def changed_cookbooks(paths = nil, bump_check: true)
  changed_cookbooks = []
  paths ||= ARGV
  paths.each do |file|
    cookbook, type = metadata_walk(file)
    next if cookbook == false || changed_cookbooks.map(&:first).include?(cookbook) || file.include?('/test/')

    next if bump_check && !bump_required?(file)

    changed_cookbooks << [cookbook, type]
  end
  changed_cookbooks.sort!
  changed_cookbooks
end
