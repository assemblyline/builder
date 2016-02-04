require "spec_helper"
require "component"

describe Component do
  let(:data) do
    {
      "component" => {
        "repo" => "foo.com/foo/bar",
        "name" => "Awesome Component",
        "version" => [
          { "version" => "0.0.1" },
          { "version" => "0.0.2" },
        ],
      },
    }
  end

  let(:dir) { Dir.mktmpdir }
  let(:git_sha) { "ef60fd" }

  after do
    FileUtils.rm_rf dir
  end

  subject { described_class.new(data, dir, git_sha) }

  let(:builder) { double }

  before do
    expect(Builder::Component).to receive(:new).and_return(builder)
  end

  describe "#build" do
    it "calls the builder" do
      expect(builder).to receive(:build)
      subject.build
    end
  end

  describe "#push" do
    let(:i1) { double(info: { "RepoTags" => ["foo.com/bar:1.0.0"] }) }
    let(:i2) { double(info: { "RepoTags" => ["foo.com/bar:2.0.0"] }) }

    before do
      ENV["DOCKERCFG"] = "{\"https://index.docker.io/v1/\":{\"auth\":\"ZXJybTpwYXNzd29yZA\",\"email\":\"ed@reevoo.com\"}}" # rubocop:disable Metrics/LineLength
      allow(builder).to receive(:build).and_return([i1, i2])
      allow(Docker).to receive(:authenticate!)
      subject.build
    end

    it "pushes each of the images" do
      expect(Docker).to receive(:authenticate!).with(
        "email" => "ed@reevoo.com",
        "username" => "errm",
        "password" => "password",
        "serveraddress" => "https://index.docker.io/v1/",
      )

      expect(i1).to receive(:push)
      expect(i2).to receive(:push)

      subject.push
    end

    it "logs the correct output" do
      allow(i1).to receive(:push)
      allow(i2).to receive(:push)

      subject.push

      expect(Log.out.string).to include "pushing foo.com/bar:1.0.0"
      expect(Log.out.string).to include "pushing foo.com/bar:2.0.0"
    end
  end
end
