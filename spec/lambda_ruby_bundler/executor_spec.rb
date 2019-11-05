# frozen_string_literal: true

RSpec.describe LambdaRubyBundler::Executor do
  describe '#run' do
    subject(:run) { executor.run }

    let(:build_dependencies) { true }

    let(:extractor) do
      proc do |io|
        stream = Zip::InputStream.new(io)
        entry = nil

        [].tap do |entries|
          entries << entry.name while (entry = stream.get_next_entry)
        end
      end
    end

    let(:application_bundle_entries) do
      extractor.call(run[:application_bundle])
    end

    let(:dependency_layer_entries) do
      extractor.call(run[:dependency_layer])
    end

    context 'when application has no runtime dependencies' do
      include_context 'with application', :no_deps

      it_behaves_like 'application bundler', %w[app.rb Gemfile Gemfile.lock], []
    end

    context 'when application has dependency without native extensions' do
      include_context 'with application', :regular_dep

      it_behaves_like 'application bundler',
                      %w[default_handler.rb], [%r{gems/rake-13.0.0}]
    end

    context 'when application has dependency with native extensions' do
      include_context 'with application', :extension_dep

      let(:extension_library_name) do
        '/extensions/x86_64-linux/2.5.0-static/' \
          'jaro_winkler-1.5.4/jaro_winkler/jaro_winkler_ext.so'
      end

      it_behaves_like 'application bundler',
                      %w[default_handler.rb], [%r{gems/jaro_winkler-1.5.4}]

      it 'builds extension' do
        expect(dependency_layer_entries)
          .to include match(/#{extension_library_name}/)
      end
    end
  end
end
