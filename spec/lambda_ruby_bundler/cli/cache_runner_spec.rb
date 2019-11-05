# frozen_string_literal: true

require 'lambda_ruby_bundler/cli/cache_runner'

RSpec.describe LambdaRubyBundler::CLI::CacheRunner do
  include_context 'with application', :regular_dep

  let(:cache_dir) { File.expand_path('../../tmp', __dir__) }
  let(:cache_runner) { described_class.new(root_path, app_path, cache_dir) }

  describe '#run' do
    subject(:run) { cache_runner.run }

    after do
      Dir.chdir(cache_dir) { Dir['*.zip'].each { |file| FileUtils.rm(file) } }
    end

    context 'when no files are cached' do
      let(:expected_files) do
        %w[build-ea0bee47006f367bed582487677373f7.zip
           builddep-8039ff1e0a67a903637112f513333448.zip]
      end

      it 'creates two bundles' do
        expect { run }
          .to change { Dir.chdir(cache_dir) { Dir['*.zip'] } }
          .to expected_files
      end
    end

    context 'when there are cached builds' do
      let(:valid_application_hash) { 'ea0bee47006f367bed582487677373f7' }
      let(:valid_dependency_hash) { '8039ff1e0a67a903637112f513333448' }

      let(:cached_application_hash) { valid_application_hash }
      let(:cached_dependency_hash) { valid_dependency_hash }

      let(:cached_application_path) do
        File.join(cache_dir, "build-#{cached_application_hash}.zip")
      end

      let(:cached_dependency_path) do
        File.join(cache_dir, "builddep-#{cached_dependency_hash}.zip")
      end

      before do
        File.write(cached_application_path, '1')
        File.write(cached_dependency_path, '2')

        allow(LambdaRubyBundler::Executor).to receive(:new).and_call_original
      end

      context 'with expired application code' do
        let(:cached_application_hash) { valid_application_hash.reverse }

        it 'does not build dependencies' do
          run

          expect(LambdaRubyBundler::Executor)
            .to have_received(:new).with(root_path, app_path, false)
        end

        it 'removes old bundle' do
          expect { run }
            .to change { File.exist?(cached_application_path) }
            .to(false)
        end
      end

      context 'when no builds are expired' do
        it 'does not run executor' do
          run

          expect(LambdaRubyBundler::Executor).not_to have_received(:new)
        end
      end
    end
  end
end
