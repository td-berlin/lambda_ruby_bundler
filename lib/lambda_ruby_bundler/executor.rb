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
  #       'backend'
  #     )
  #
  #     File.write('bundle.zip', executor.run.read)
  #
  #     # Note that resulting structure of the ZIP will be flattened!
  #     # + handler.rb
  #     # + vendor/bundle/...
  class Executor
    attr_reader :root_path, :app_path

    # Creates new instance of the Executor.
    #
    # @param [String] root_path
    #   Path to the root of the application (with Gemfile)
    # @param [String] app_path
    #   Path to the Ruby application code, relative to root.
    def initialize(root_path, app_path)
      @root_path = root_path
      @app_path = app_path
    end

    # Generates the ZIP contents.
    #
    # @return [StringIO] IO containing contents of the ZIP
    def run
      zipped_contents, = container.run.tap { container.destroy }

      StringIO.new(zipped_contents.join)
    end

    private

    def application_name
      @application_name ||= File.basename(root_path)
    end

    def container
      @container ||= Container.new(root_path, app_path, volume)
    end

    def volume
      @volume ||= Volume.new(application_name)
    end
  end
end
