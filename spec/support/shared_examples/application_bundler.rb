# frozen_string_literal: true

RSpec.shared_examples_for 'application bundler' do |application_files, gems|
  it 'contains application files' do
    expect(application_bundle_entries).to include(*application_files)
  end

  it 'does not bundle any gems in application bundle' do
    expect(application_bundle_entries).to_not include match(/gems/)
  end

  if gems.any?
    let(:gem_matchers) { gems.map { |gem| match(gem) } }

    it 'bundles gems in dependency layer' do
      expect(dependency_layer_entries).to include(*gem_matchers)
    end
  end

  context 'when dependency bundling is disabled' do
    let(:build_dependencies) { false }

    it 'contains application files' do
      expect(application_bundle_entries).to include(*application_files)
    end

    it 'does not include dependency layer' do
      expect(run).not_to have_key(:dependency_layer)
    end
  end
end
