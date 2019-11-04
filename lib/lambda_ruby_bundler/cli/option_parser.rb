# frozen_string_literal: true

require 'optparse'

module LambdaRubyBundler
  module CLI
    # Custom OptionParser which collects user-supplied options about the build.
    # @api private
    class OptionParser < ::OptionParser
      attr_reader :options

      def initialize
        @options = {
          root_path: Dir.pwd,
          app_path: '.',
          output_path: 'build.zip'
        }

        super do |builder|
          root_path_option(builder)
          app_path_option(builder)
          output_option(builder)
        end
      end

      def parse!(*)
        super
        options
      end

      private

      def root_path_option(builder)
        builder.on(
          '--root-path=ROOT_PATH',
          'Sets root path (containing Gemfile) of the application' \
          ' (defaults to current directory)'
        ) do |path|
          options[:root_path] = File.expand_path(path)
        end
      end

      def app_path_option(builder)
        builder.on(
          '--app-path=APP_PATH',
          'Sets application path (relative to root) with the application code' \
          ' (defaults to current directory)',
          &assign_option(:app_path)
        )
      end

      def output_option(builder)
        builder.on(
          '--out=OUT_PATH',
          'Sets output path, to which the ZIP with the bundled code ' \
          'will be saved',
          &assign_option(:output_path)
        )
      end

      def assign_option(option)
        proc { |value| options[option] = value }
      end
    end
  end
end
