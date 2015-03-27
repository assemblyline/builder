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
  let(:runner) { double(:runner, run: nil) }

  before do
    allow(Docker::Image).to receive(:create)
    allow(Docker::Container).to receive(:create).and_return(container)
  end

  describe 'the build script' do

    before do
      allow(subject).to receive(:package_target)
    end

    it 'cd into the application path' do
      expect(ContainerRunner).to receive(:new) do |args|
        expect(args[:script]).to include "cd #{path}"
        runner
      end
      subject.build
    end

    context 'in an npm project' do
      let(:path) { "#{base_path}/npm" }

      it 'runs npm install' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include 'npm install'
          runner
        end
        subject.build
      end
    end

    context 'in a bower project' do
      let(:path) { "#{base_path}/bower" }

      it 'runs bower install' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include 'bower install --allow-root'
          runner
        end
        subject.build
      end
    end

    context 'in a grunt project' do
      let(:path) { "#{base_path}/grunt" }

      it 'runs grunt' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include 'grunt'
          runner
        end
        subject.build
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
          runner
        end
        subject.build
      end
    end

    context 'when a script is specified' do
      let(:build) { { 'script' => ['echo foo', 'echo bar'] } }

      it 'cd into the application path' do
        expect(ContainerRunner).to receive(:new) do |args|
          expect(args[:script]).to include "cd #{path}"
          runner
        end
        subject.build
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
          runner
        end
        subject.build
      end
    end
  end

  describe '#build' do

    let(:packaged_image) { double(:packaged_image, tag: nil) }
    let(:runner) { double }

    before do
      FileUtils.mkdir_p(File.join(base_path, 'dist'))
      allow(Docker::Image).to receive(:build_from_dir).and_return(packaged_image)
      allow(ContainerRunner).to receive(:new).and_return(runner)
    end

    after do
      FileUtils.rm_rf(File.join(base_path, 'dist'))
    end

    it 'starts the build container' do
      expect(runner).to receive(:run)
      expect(subject.build).to eq packaged_image
    end
  end
end
