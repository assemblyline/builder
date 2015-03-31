require 'spec_helper'
require 'builder/dockerfile'

describe Builder::Dockerfile do
  let(:application) { double(:application, path: '/foo/bar', repo: 'foo.com/foo/bar',  tag: 'taaaGGGGG') }
  let(:image) { double(:image) }
  subject { described_class.new(application: application) }

  describe 'doing the docker build' do
    it 'returns a built and tagged image' do
      expect(Docker::Image).to receive(:build_from_dir).with('/foo/bar', 'pull' => true).and_return(image)
      expect(image).to receive(:tag).with('repo' => 'foo.com/foo/bar', 'tag' => 'taaaGGGGG', 'force' => true)
      expect(subject.build).to eq image
    end

    context 'when passing in a path' do
      subject { described_class.new(application: application, path: '/some/other/path') }

      before do
        allow(image).to receive(:tag)
      end

      it 'uses the passes in path rather than the application path' do
        expect(Docker::Image).to receive(:build_from_dir).with('/some/other/path', 'pull' => true).and_return(image)
        subject.build
      end
    end
  end
end
