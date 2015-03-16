require 'spec_helper'
require 'builder/dockerfile'

describe Builder::Dockerfile do
  let(:application) { double(:application, path: Dir.pwd) }
  let(:git_sha) { `git rev-parse --short HEAD`.chomp }
  subject { described_class.new(application: application, build: { 'repo' => 'quay.io/foo/bar-baz' } ) }

  describe 'doing the docker build' do
    before do
      allow(Time).to receive(:now).and_return(Time.at(1426533532))
    end

    it 'shells out to the docker client' do
      expect(subject).to receive(:system).with("docker build -t quay.io/foo/bar-baz:#{git_sha}_20150316191852 #{Dir.pwd}")
      subject.build
    end
  end
end
