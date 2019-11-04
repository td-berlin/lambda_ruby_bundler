# frozen_string_literal: true

RSpec.describe LambdaRubyBundler::Executor do
  describe '#run' do
    subject(:run) { executor.run }

    let(:entries) do
      stream = Zip::InputStream.new(run)
      entry = nil

      [].tap do |entries|
        entries << entry.name while (entry = stream.get_next_entry)
      end
    end

    context 'when application has no runtime dependencies' do
      include_context 'with application', :no_deps

      it 'contains application files' do
        expect(entries).to include('app.rb', 'Gemfile', 'Gemfile.lock')
      end

      it 'does not bundle any gems' do
        expect(entries).to_not include match(/gems/)
      end
    end

    context 'when application has dependency without native extensions' do
      include_context 'with application', :regular_dep

      it 'contains application files' do
        expect(entries).to include('default_handler.rb')
      end

      it 'bundles production gem' do
        expect(entries).to include match(%r{gems/rake-13.0.0})
      end
    end

    context 'when application has dependency with native extensions' do
      include_context 'with application', :extension_dep

      let(:extension_library_name) do
        '/extensions/x86_64-linux/2.5.0-static/' \
          'jaro_winkler-1.5.4/jaro_winkler/jaro_winkler_ext.so'
      end

      it 'contains application files' do
        expect(entries).to include('default_handler.rb')
      end

      it 'bundles production gem' do
        expect(entries).to include match(%r{gems/jaro_winkler-1.5.4})
      end

      it 'builds extension' do
        expect(entries).to include match(/#{extension_library_name}/)
      end
    end
  end
end
