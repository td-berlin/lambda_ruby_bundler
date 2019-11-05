#!/usr/bin/env ruby
# frozen_string_literal: true

# Packager script run inside the container

require 'fileutils'
require 'json'
require 'base64'

APPLICATION_DIRECTORY, = ARGV

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

# Copy application directory contents
contents = File.join('/app', APPLICATION_DIRECTORY, '.')
FileUtils.cp_r(contents, '/workspace/build')

# Zip the contents and print
silent('cd /workspace/build && zip -r /tmp/out.zip .')

# Read and serialize the resulting ZIP
serialized_app_bundle = Base64.strict_encode64(File.read('/tmp/out.zip'))

puts({ application_bundle: serialized_app_bundle }.to_json)
