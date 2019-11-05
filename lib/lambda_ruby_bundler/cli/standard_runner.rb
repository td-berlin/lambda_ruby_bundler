# frozen_string_literal: true

module LambdaRubyBundler
  module CLI
    # Runs the executor with given parameters.
    class StandardRunner < BaseRunner
      attr_reader :build_dependencies, :paths

      # Creates new instance of cache runner.
      #
      # @param [String] root_path
      #   Path to the root of application (containing Gemfile.lock)
      # @param [String] app_path
      #   Path (relative to root_path) containing application code
      # @param [Boolean] build_dependencies
      #   Whether or not to build dependencies
      # @param [Hash] paths
      #   Hash with :application_bundle and :dependency_layer output paths
      def initialize(root_path, app_path, build_dependencies, paths)
        super(root_path, app_path)
        @build_dependencies = build_dependencies
        @paths = paths
      end

      # Runs the executo. Returns hash with two keys:
      #   :application_bundle => path to the application code bundle
      #   :dependency_layer => path to dependency bundle
      #
      # @return [Hash] Paths to the builds
      def run
        bundle(build_dependencies)
      end
    end
  end
end
