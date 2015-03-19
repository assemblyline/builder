require 'spec_helper'
require 'builder/dockerfile'

describe Builder::Dockerfile do
  let(:application) { double(:application, path: '/foo/bar', full_tag: 'foo.com/foo/bar:awesome') }
  subject { described_class.new(application: application, build: {}) }

  describe 'doing the docker build' do
    it 'shells out to the docker client with the correct args' do
      expect(subject).to receive(:system).with('docker build -t foo.com/foo/bar:awesome /foo/bar')
      subject.build
    end
  end
end
