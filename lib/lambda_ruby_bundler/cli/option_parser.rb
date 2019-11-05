# frozen_string_literal: true

module LambdaRubyBundler
  module CLI
    # Custom OptionParser which collects user-supplied options about the build.
    # @api private
    class OptionParser < ::OptionParser
      attr_reader :options

      OPTIONS = %i[
        root_path_option
        app_path_option
        output_option
        no_dependencies_option
        dependencies_path_option
        cache_dir_option
      ].freeze

      def initialize
        @options = defaults

        super { |builder| OPTIONS.each { |option| send(option, builder) } }
      end

      def parse!(*)
        super

        options[:dependencies_path] ||= build_default_dependencies_path(
          options[:output_path]
        )

        options
      end

      private

      def defaults
        {
          root_path: Dir.pwd,
          app_path: '.',
          build_dependencies: true,
          dependencies_path: nil,
          output_path: 'build.zip',
          cache_dir: nil
        }
      end

      def build_default_dependencies_path(output_path)
        File.join(
          File.dirname(output_path),
          [File.basename(output_path, '.*'), 'dependencies.zip'].join('-')
        )
      end

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

      def no_dependencies_option(builder)
        builder.on(
          '--no-dependencies', 'Prevents building dependency layer'
        ) do |option|
          options[:build_dependencies] = option
        end
      end

      def dependencies_path_option(builder)
        builder.on(
          '--dependencies-path=APP_PATH',
          'Sets path for the dependencies layer package (defaults to ' \
          '{OUT_PATH}-dependencies.zip)',
          &assign_option(:dependencies_path)
        )
      end

      def cache_dir_option(builder)
        builder.on(
          '--cache-dir=CACHE_DIR',
          'Enables Cache Mode and uses chosen directory as target directory ' \
          'for the builds.',
          &assign_option(:cache_dir)
        )
      end

      def assign_option(option)
        proc { |value| options[option] = value }
      end
    end
  end
end
