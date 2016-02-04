require "spec_helper"
require "builder"
require "builder/dockerfile"

describe Builder do
  subject { described_class.new(url: "git@github.com:reevoo/awesome_app.git") }
  let(:docker_builder) { double(:docker_builder) }
  let(:git_cache) { double(:git_cache) }

  before do
    allow(Builder::Dockerfile).to receive(:new).and_return(docker_builder)
    allow(GitCache).to receive(:new).and_return(git_cache)
  end

  it "it can build the app" do
    expect(git_cache).to receive(:make_working_copy).and_yield("/tmp/foo-bah", "sha")
    app = double
    expect(Assemblyfile).to receive(:load).with("/tmp/foo-bah", "sha").and_return([app])
    expect(app).to receive(:build)
    subject.build
  end

  it "can build and push the app" do
    expect(git_cache).to receive(:make_working_copy).and_yield("/tmp/foo-bah", "sha")
    app = double
    expect(Assemblyfile).to receive(:load).with("/tmp/foo-bah", "sha").and_return([app])
    expect(app).to receive(:build)
    expect(app).to receive(:push)
    subject.build(push: true)
  end
end
