# frozen_string_literal: true

RSpec.describe LambdaRubyBundler::CLI::StandardRunner do
  include_context 'with application', :regular_dep

  let(:tmp_dir) { File.expand_path('../../tmp', __dir__) }
  let(:runner) { described_class.new(root_path, app_path, false, paths) }

  let(:paths) do
    {
      application_bundle: File.join(tmp_dir, 'build.zip'),
      dependency_layer: File.join(tmp_dir, 'deps.zip')
    }
  end

  describe '#run' do
    subject(:run) { runner.run }

    let(:expected_files) { %w[build.zip] }

    after do
      Dir.chdir(tmp_dir) { Dir['*.zip'].each { |file| FileUtils.rm(file) } }
    end

    it 'creates requested bundles' do
      expect { run }
        .to change { Dir.chdir(tmp_dir) { Dir['*.zip'] } }
        .to expected_files
    end
  end
end
