# frozen_string_literal: true

module LambdaRubyBundler
  # Wrapper around [Docker::Container] for creating, running and removing
  # bundler containers.
  # @api private
  class Container
    attr_reader :root_path, :app_path, :volume, :build_dependencies

    def initialize(root_path, app_path, volume, build_dependencies)
      @root_path = root_path
      @app_path = app_path
      @volume = volume
      @build_dependencies = build_dependencies
    end

    def run(timeout: 120)
      container.start

      container.attach({}, read_timeout: timeout)
    end

    def destroy
      container.remove
      @container = nil
    end

    private

    def container
      @container ||= Docker::Container.create(container_arguments)
    end

    def container_arguments
      { 'Cmd' => [app_path, build_dependencies ? 'use-deps' : 'no-deps'],
        'Image' => Image.instance.id,
        'HostConfig' => {
          'AutoRemove' => true,
          'Mounts' => mounts
        } }
    end

    def mounts
      [
        { 'Target' => '/app',
          'Source' => root_path,
          'Type' => 'bind',
          'ReadOnly' => true },
        { 'Target' => '/workspace/build/vendor/bundle',
          'Source' => volume.id,
          'Type' => 'volume' }
      ]
    end
  end
end
