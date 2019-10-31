# frozen_string_literal: true

module LambdaRubyBundler
  # Wrapper around [Docker::Image] for building the image for the bundler
  # containers.
  # @api private
  class Image
    include Singleton
    extend Forwardable

    delegate id: :@image

    def initialize
      @image = Docker::Image.build_from_dir(__dir__, 't' => tag)
    end

    def tag
      @tag ||= [
        'lambda-ruby-bundler',
        VERSION
      ].join(':')
    end
  end
end
