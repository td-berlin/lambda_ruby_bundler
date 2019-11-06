# frozen_string_literal: true

module LambdaRubyBundler
  module CLI
    # Runs the executor.
    # @api private
    class BaseRunner
      attr_reader :root_path, :app_path

      def initialize(root_path, app_path)
        @root_path = root_path
        @app_path = app_path
      end

      private

      def bundle(build_dependencies)
        executor = LambdaRubyBundler::Executor.new(
          root_path, app_path, build_dependencies
        )

        result = executor.run

        save(result[:application_bundle], paths[:application_bundle])
        return unless build_dependencies

        save(result[:dependency_layer], paths[:dependency_layer])
      end

      def save(io, path)
        File.open(path, 'wb+') { |file| file.write(io.read) }
      end
    end
  end
end
