require 'spec_helper'
require 'builder/component'

describe Builder::Component do
  subject { described_class.new(component: component, versions: versions) }
  let(:component) { double }
  let(:versions) { double }

  let(:version1) { double }
  let(:version2) { double }

  before do
    allow(Builder::Component::Version).to receive(:versions)
      .with(component: component, versions: versions)
      .and_return([version1, version2])
  end

  describe '#build' do
    it 'calls build on each version and returns the result to the caller' do
      expect(version1).to receive(:build).and_return('foo')
      expect(version2).to receive(:build).and_return('bar')
      expect(subject.build).to eq %w(foo bar)
    end
  end

end

describe Builder::Component::Version do
  let(:component) { double(:component, repo: 'quay.io/assemblyline/java') }
  let(:versions) { [data] }
  let(:data) { { 'version' => '1.8.0' } }

  subject { described_class.new(component: component, data: data, versions: versions) }

  describe '#tag' do
    it 'takes the tag from data' do
      expect(subject.tag).to eq '1.8.0'
    end
  end

  describe '#repo' do
    it 'takes the repo from the component' do
      expect(subject.repo).to eq 'quay.io/assemblyline/java'
    end
  end

  describe '#template_paths' do
    let(:versions) { [data, { 'version' => '0.0.2' }, { 'version' => '0.0.3' }] }

    let(:component) do
      double(:component, repo: 'quay.io/assemblyline/java', path: 'spec/fixtures/components/simple_component')
    end

    context 'there is a version specific template' do
      let(:data) { { 'version' => '0.0.1' } }

      it 'uses the version specific template' do
        expect(subject.template_paths).to include "#{component.path}/templates/0.0.1/Dockerfile.erb"
        expect(subject.template_paths).to_not include "#{component.path}/templates/Dockerfile.erb"
      end
    end

    context 'there is a version specifc folder but no file' do
      let(:data) { { 'version' => '0.0.1' } }

      it 'uses the generic template' do
        expect(subject.template_paths).to include "#{component.path}/templates/config.yml.erb"
      end
    end

    context 'there is not a version specific template' do
      let(:versions) { [data, { 'version' => '0.0.1' }, { 'version' => '0.0.3' }] }
      let(:data) { { 'version' => '0.0.2' } }

      it 'uses the generic template' do
        expect(subject.template_paths).to include "#{component.path}/templates/Dockerfile.erb"
        expect(subject.template_paths).to include "#{component.path}/templates/config.yml.erb"
        expect(subject.template_paths).to_not include "#{component.path}/templates/0.0.1/Dockerfile.erb"
      end
    end
  end
end
