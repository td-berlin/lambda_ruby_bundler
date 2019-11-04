# frozen_string_literal: true

module LambdaRubyBundler
  # Wrapper around [Docker::Volume] for creating and fetching bundler volumes,
  # which are used to cache built gems. This speeds up the process
  # significantly.
  # @api private
  class Volume
    NAME_TEMPLATE = 'lambda-ruby-bundler-%<app>s-volume'

    attr_reader :application_name

    def initialize(application_name)
      @application_name = application_name
    end

    def id
      volume.id
    end; alias name id

    private

    def volume
      @volume ||= fetch_volume
    end

    def fetch_volume
      name = format(NAME_TEMPLATE, app: application_name)

      Docker::Volume.get(name)
    rescue Docker::Error::NotFoundError
      Docker::Volume.create(name)
    end
  end
end
