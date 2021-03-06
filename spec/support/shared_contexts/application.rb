# frozen_string_literal: true

RSpec.shared_context 'with application' do |application_name|
  let(:application_paths) do
    {
      extension_dep: 'app',
      regular_dep: 'app',
      no_deps: '.'
    }
  end

  let(:app_path) { application_paths[application_name] }
  let(:root_path) do
    File.expand_path(File.join('..', 'apps', application_name.to_s), __dir__)
  end

  let(:build_dependencies) { true }

  let(:executor) do
    LambdaRubyBundler::Executor.new(root_path, app_path, build_dependencies)
  end

  after do
    executor.send(:volume).send(:volume).remove
  end
end
