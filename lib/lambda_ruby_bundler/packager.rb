#!/usr/bin/env ruby
# frozen_string_literal: true

# Packager script run inside the container

require 'fileutils'
require 'json'
require 'base64'

APPLICATION_DIRECTORY, = ARGV
BUNDLE_DEPS = ARGV.include?('use-deps')

def silent(command)
  system(command, out: File::NULL, err: File::NULL)
end

def bundle_install(*additional_options)
  [
    'bundle install',
    '--path build/vendor/bundle',
    *additional_options
  ].join(' ')
end

RUBY_ENTRY_REGEX = /\A\s*ruby\s+("|')\d+\.\d+\.\d+("|')\s*\z/.freeze

result = {}

if BUNDLE_DEPS
  # Copy Gemfile and Gemfile.lock to the workspace
  FileUtils.cp('/app/Gemfile', '/workspace/Gemfile')
  FileUtils.cp('/app/Gemfile.lock', '/workspace/Gemfile.lock')

  # Clean Ruby version requirement from Gemfile
  contents = File.read('/workspace/Gemfile').lines
  contents.reject! { |line| RUBY_ENTRY_REGEX.match(line) }
  File.write('/workspace/Gemfile', contents.join)

  # Check if all gems are installed
  all_installed = silent(bundle_install('--local'))

  # Install if some gems are missing locally
  silent(bundle_install) unless all_installed

  # Clean unused gems
  silent('bundle clean')

  # Create proper structure for AWS Layer
  FileUtils.mkdir_p('/tmp/layer/ruby/gems')
  FileUtils.symlink(
    '/workspace/build/vendor/bundle/ruby/2.5.0',
    '/tmp/layer/ruby/gems/2.5.0'
  )

  # Zip the dependencies
  silent('cd /tmp/layer && zip -r /tmp/dependencies.zip .')

  # Add serialized ZIP to result
  content = File.read('/tmp/dependencies.zip')
  result[:dependency_layer] = Base64.strict_encode64(content)
end

# Zip the application code
app_path = File.join('/app', APPLICATION_DIRECTORY)
silent("cd #{app_path} && zip -r /tmp/app.zip .")

# Add serialized ZIP to result
content = File.read('/tmp/app.zip')
result[:application_bundle] = Base64.strict_encode64(content)

puts(result.to_json)
