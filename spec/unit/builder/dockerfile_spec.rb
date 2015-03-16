require 'builder/dockerfile'

describe Builder::Dockerfile do
  let(:application) { double(:application, path: '/foo/bah/path') }
  subject { described_class.new(application: application, build: { 'repo' => 'quay.io/foo/bar-baz' } ) }

  describe 'doing the docker build' do
    it 'shells out to the docker client' do
      expect(subject).to receive(:system).with('docker build -t quay.io/foo/bar-baz /foo/bah/path')
      subject.build
    end
  end
end
