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

    xit 'runs the script with bash' do
      expect(Docker::Container).to receive(:create) do |options|
        expect(options['Cmd'].first(2)).to eq ['bash', '-xce']
      end
      subject
    end

    it 'cd into the application path' do
      expect(ContainerRunner).to receive(:new) do |args|
        expect(args[:script]).to include "cd #{path}"
      end
      subject
    end

    context 'in an npm project' do
      let(:path) { "#{base_path}/npm" }

      it 'runs npm install' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include 'npm install'
        end
        subject
      end
    end

    context 'in a bower project' do
      let(:path) { "#{base_path}/bower" }

      it 'runs bower install' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include 'bower install --allow-root'
        end
        subject
      end
    end

    context 'in a grunt project' do
      let(:path) { "#{base_path}/grunt" }

      it 'runs grunt' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include 'grunt'
        end
        subject
      end
    end

    context 'all the things' do
      it 'runs the expected commands in sequence' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to eq [
            "cd #{path}",
            'node --version',
            'npm --version',
            'bower --version',
            'grunt --version',
            'npm install',
            'bower install --allow-root',
            'grunt',
          ]
        end
        subject
      end
    end

    context 'when a script is specified' do
      let(:build) { { 'script' => ['echo foo', 'echo bar'] } }

      it 'cd into the application path' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include "cd #{path}"
        end
        subject
      end

      it 'uses the script' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to eq([
            "cd #{path}",
            'node --version',
            'npm --version',
            'bower --version',
            'grunt --version',
            'echo foo',
            'echo bar',
          ])
        end
        subject
      end
    end
  end

  describe '#build' do

    let(:packaged_image) { double(:packaged_image, tag: nil) }
    let(:runner) { double }

    before do
      allow(Docker::Image).to receive(:build_from_dir).and_return(packaged_image)
      allow(ContainerRunner).to receive(:new).and_return(runner)
    end

    it 'starts the build container' do
      expect(runner).to receive(:run)
      expect(subject.build).to eq packaged_image
    end
  end
end
