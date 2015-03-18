require 'spec_helper'
require 'builder/frontendjs'

describe Builder::FrontendJS do
  let(:base_path) { File.expand_path('spec/fixtures/frontendjs_projects') }
  let(:path) { base_path }
  let(:application) { double(:application, path: path, repo: 'quay.io/assemblyline/awesome', tag: 'foo_bah') }
  let(:build) { {} }

  subject { described_class.new(application: application, build: build) }

  let(:container_json) { { 'State' => { 'ExitCode' => 0 } } }
  let(:container) { double(:container, start: nil, attach: nil, json: container_json, delete: nil) }

  before do
    allow(Docker::Image).to receive(:create)
    allow(Docker::Container).to receive(:create).and_return(container)
  end

  describe 'the build script' do
    it 'cd into the application path' do
      expect(Docker::Container).to receive(:create) do |options|
        expect(options['Cmd'].last).to include "cd #{path}"
      end
      subject
    end

    context 'in an npm project' do
      let(:path) { "#{base_path}/npm" }

      it 'runs npm install' do
        expect(Docker::Container).to receive(:create) do |options|
          expect(options['Cmd'].last).to include "npm install"
        end
        subject
      end
    end

    context 'in a bower project' do
      let(:path) { "#{base_path}/bower" }

      it 'runs bower install' do
        expect(Docker::Container).to receive(:create) do |options|
          expect(options['Cmd'].last).to include "bower install --allow-root"
        end
        subject
      end
    end

    context 'in a grunt project' do
      let(:path) { "#{base_path}/grunt" }

      it 'runs grunt' do
        expect(Docker::Container).to receive(:create) do |options|
          expect(options['Cmd'].last).to include "grunt"
        end
        subject
      end
    end

    context 'all the things' do
      it 'runs the expected commands in sequence' do
        expect(Docker::Container).to receive(:create) do |options|
          expect(options['Cmd'].last).to eq "cd #{path} && npm install && bower install --allow-root && grunt"
        end
        subject
      end
    end

    context 'when a script is specified' do
      let(:build) { { 'script' => ['echo foo', 'echo bar'] } }

      it 'cd into the application path' do
        expect(Docker::Container).to receive(:create) do |options|
          expect(options['Cmd'].last).to include "cd #{path}"
        end
        subject
      end

      it 'uses the script' do
        expect(Docker::Container).to receive(:create) do |options|
          expect(options['Cmd'].last).to eq "cd #{path} && echo foo && echo bar"
        end
        subject
      end
    end
  end

  describe '#build' do

    let(:packaged_image) { double(:packaged_image, tag: nil) }

    before do
      FileUtils::mkdir_p base_path + '/dist'
      allow(Docker::Image).to receive(:build_from_dir).and_return(packaged_image)
    end

    it 'starts the build container' do
      expect(container).to receive(:start)
      subject.build
    end
  end
end
