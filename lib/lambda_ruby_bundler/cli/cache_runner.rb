# frozen_string_literal: true

module LambdaRubyBundler
  module CLI
    # Runs the executor in Cache Mode.
    class CacheRunner < BaseRunner
      MD5_EXTRACT_REGEX = /build(?:dep)?-([a-f0-9]{32}).zip/.freeze

      attr_reader :cache_dir

      # Creates new instance of cache runner.
      #
      # @param [String] root_path
      #   Path to the root of application (containing Gemfile.lock)
      # @param [String] app_path
      #   Path (relative to root_path) containing application code
      # @param [String]
      #   cache_dir Directory containing cached builds
      def initialize(root_path, app_path, cache_dir)
        super(root_path, app_path)
        @cache_dir = cache_dir
      end

      # Runs the executor, if necessary. Returns hash with two keys:
      #   :application_bundle => path to the application code bundle
      #   :dependency_layer => path to dependency bundle
      #
      # @return [Hash] Paths to the builds
      def run
        build_dependencies = !dependencies_builds.key?(dependencies_hash)
        build_application = !application_builds.key?(application_hash)

        if build_application || build_dependencies
          clear_cache
          bundle(build_dependencies)
        end

        paths
      end

      private

      def clear_cache
        (application_builds.values + dependencies_builds.values).each do |file|
          FileUtils.rm(file)
        end
      end

      def paths
        @paths ||= {
          application_bundle:
            File.join(cache_dir, "build-#{application_hash}.zip"),
          dependency_layer:
            File.join(cache_dir, "builddep-#{dependencies_hash}.zip")
        }
      end

      def application_hash
        @application_hash ||= begin
          files = Dir[File.join(root_path, app_path, '**', '*')]
          digest = Digest::MD5.new

          files.each do |file|
            digest << File.read(file) if File.file?(file)
          end

          digest.hexdigest
        end
      end

      def dependencies_hash
        @dependencies_hash ||= begin
          path = File.join(root_path, 'Gemfile.lock')
          content = File.read(path)
          Digest::MD5.hexdigest(content)
        end
      end

      def application_builds
        @application_builds ||= fetch_builds('build-*.zip')
      end

      def dependencies_builds
        @dependencies_builds ||= fetch_builds('builddep-*.zip')
      end

      def fetch_builds(name_glob)
        Dir[File.join(cache_dir, name_glob)]
          .group_by(&method(:extract_md5))
          .transform_values(&:first)
          .tap { |result| result.delete(nil) }
      end

      def extract_md5(path)
        MD5_EXTRACT_REGEX.match(path)&.captures&.at(0)
      end
    end
  end
end
