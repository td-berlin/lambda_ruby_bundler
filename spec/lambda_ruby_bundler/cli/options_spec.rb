# frozen_string_literal: true

require 'lambda_ruby_bundler/cli/option_parser'

RSpec.describe LambdaRubyBundler::CLI::OptionParser do
  let(:options_parser) { described_class.new }

  describe '#parse' do
    subject { options_parser.parse!(arguments) }

    context 'when no arguments given' do
      let(:arguments) { [] }

      let(:expected_options) do
        {
          root_path: Dir.pwd,
          app_path: '.',
          output_path: 'build.zip',
          build_dependencies: true,
          dependencies_path: './build-dependencies.zip'
        }
      end

      it { is_expected.to eq expected_options }
    end

    context 'when all arguments given' do
      let(:arguments) do
        [
          '--root-path',
          'app',
          '--app-path',
          'code',
          '--out',
          '/tmp/build.zip',
          '--no-dependencies',
          '--dependencies-path',
          '/tmp/deps.zip'
        ]
      end

      let(:expected_options) do
        {
          root_path: File.join(Dir.pwd, 'app'),
          app_path: 'code',
          output_path: '/tmp/build.zip',
          build_dependencies: false,
          dependencies_path: '/tmp/deps.zip'
        }
      end

      it { is_expected.to eq expected_options }
    end
  end
end
