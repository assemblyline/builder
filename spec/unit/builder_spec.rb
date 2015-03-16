require 'builder'
require 'builder/dockerfile'

describe Builder do
  subject { described_class.new(url: "git@github.com:reevoo/fast_response.git") }
  let(:docker_builder) { double(:docker_builder) }
  let(:git_cache) { double(:git_cache) }

  before do
    allow(Builder::Dockerfile).to receive(:new).and_return(docker_builder)
    allow(GitCache).to receive(:new).and_return(git_cache)
  end

  specify do
    expect(git_cache).to receive(:make_working_copy)
    subject.build
  end
end
