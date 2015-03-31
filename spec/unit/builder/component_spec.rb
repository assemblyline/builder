require 'spec_helper'
require 'builder/component'

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
