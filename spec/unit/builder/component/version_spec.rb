require 'spec_helper'
require 'builder/component/version'

describe Builder::Component::Version do
  let(:component) do
    double(:component,
           name: 'test',
           repo: 'quay.io/assemblyline/java',
           path: '/path/to/the/code',
           builder: builder,
          )
  end
  let(:builder) { double(:builder, templates: double(:templates, for: [template])) }
  let(:template) { double }
  let(:versions) { [data] }
  let(:data) { { 'version' => '1.8.0' } }

  subject { described_class.new(component: component, data: data, versions: versions) }


  describe '#tag' do
    it 'takes the tag from data' do
      expect(subject.tag).to eq '1.8.0'
    end
  end

  describe '#template' do
    it 'is nil by default' do
      expect(subject.template).to be_nil
    end

    context 'with named template in the config data' do
      let(:data) { { 'version' => '1.8.0', 'template' => 'foo' } }

      it 'is set' do
        expect(subject.template).to eq 'foo'
      end
    end
  end

  describe '#repo' do
    it 'takes the repo from the component' do
      expect(subject.repo).to eq 'quay.io/assemblyline/java'
    end
  end

  describe '#build' do
    let(:spec_runner) { double }

    before do
      allow(Builder::Component::SpecRunner).to receive(:new).and_return(spec_runner)
    end

    it 'builds the image then tests it' do
      expect(template).to receive(:write_config)
      expect(Builder::Dockerfile).to receive(:new).with(
        application: subject,
        path: '/path/to/the/code',
      ).and_return(double(build: 'built image'))
      expect(spec_runner).to receive(:run)
      expect(subject.build).to eq 'built image'
    end

    describe 'setting up the spec runner' do
      it 'passes the correct arguments' do
        expect(Builder::Component::SpecRunner).to receive(:new) do |args|
          expect(args[:path]).to eq '/path/to/the/code'
          expect(args[:version].tag).to eq '1.8.0'
          expect(args[:version_tags]).to eq(['1.8.0'])
        end
        subject
      end
    end
  end

  describe '.versions' do
    let(:data) { [{ 'version' => '1.8.0' }, { 'version' => '1.8.2' }] }

    it 'maps the data to version objects' do
      expect(described_class).to receive(:new).with(
        versions: data,
        data: { 'version' => '1.8.0' },
        component: component,
      )
      expect(described_class).to receive(:new).with(
        versions: data,
        data: { 'version' => '1.8.2' },
        component: component,
      )

      described_class.versions(component: component, versions: data)
    end
  end
end
