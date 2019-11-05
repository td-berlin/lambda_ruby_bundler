# frozen_string_literal: true

module LambdaRubyBundler
  # Main entrypoint to the application, which packages the code from given
  # directory into ZIP.
  #
  # The packaging is done inside a container resembling Lambda environment,
  # ensuring that the gems with C extensions will work there properly.
  #
  #
  # @example Default use case
  #     # Given following directory structure:
  #     # /tmp/my_serverless_app
  #     # +-- Gemfile
  #     # +-- Gemfile.lock
  #     # +-- backend/
  #     # |   +-- handler.rb
  #     # +-- node_modules/...
  #
  #     executor = LambdaRubyBundler::Executor.new(
  #       '/tmp/my_serverless_app',
  #       'backend',
  #       true
  #     )
  #
  #     result = executor.run
  #     File.write('bundle.zip', result[:application_bundle].read)
  #     File.write('dependencies.zip', result[:dependency_layer].read)
  #
  #     # Note that resulting structure of the ZIP will be flattened!
  #     # + handler.rb
  #     # + vendor/bundle/...
  class Executor
    attr_reader :root_path, :app_path, :build_dependencies

    # Creates new instance of the Executor.
    #
    # @param [String] root_path
    #   Path to the root of the application (with Gemfile)
    # @param [String] app_path
    #   Path to the Ruby application code, relative to root.
    # @param [Boolean] build_dependencies
    #   Flag whether or not to bundle the dependencies.
    #   Useful in cases when dependencies (Gemfile.lock) does not change
    #   between builds.
    def initialize(root_path, app_path, build_dependencies)
      @root_path = root_path
      @app_path = app_path
      @build_dependencies = build_dependencies
    end

    # Generates the ZIP contents.
    #
    # @return [Hash{:application_bundle, :dependency_layer => StringIO}]
    #   Hash with the zip IOs. If `build_dependencies` options was falsey,
    #   There will be no :dependency_layer key.
    def run
      zipped_contents, = container.run.tap { container.destroy }
      contents = JSON.parse(zipped_contents.join)

      decode(contents)
    end

    private

    def decode(contents)
      contents.each_with_object({}) do |(key, data), result|
        result[key.to_sym] = StringIO.new(Base64.strict_decode64(data))
      end
    end

    def application_name
      @application_name ||= File.basename(root_path)
    end

    def container
      @container ||= Container.new(
        root_path, app_path, volume, build_dependencies
      )
    end

    def volume
      @volume ||= Volume.new(application_name)
    end
  end
end
