require "spec_helper"
require "application"
require "builder/dockerfile"
require "tmpdir"
require "fileutils"

describe Application do
  let(:data) do
    {
      "application" => {
        "repo" => "foo.com/foo/bar",
        "name" => "The Worlds Best Webapp II",
      },
      "build" => { "builder" => "Dockerfile" },
    }
  end

  let(:dir) { Dir.mktmpdir }
  let(:git_sha) { "ef60fd" }

  after do
    FileUtils.rm_rf dir
  end

  subject { described_class.new(data, dir, git_sha) }


  describe "#tag" do
    it "constructs the correct tag" do
      allow(Time).to receive(:now).and_return(Time.at(1_426_533_532))
      expect(subject.tag).to eq("#{git_sha}_20150316191852")
    end

    it "the tag remains the same even if time is ticking" do
      allow(Time).to receive(:now).and_return(Time.at(1_426_533_532))
      expect(subject.tag).to eq("#{git_sha}_20150316191852")
      # Time will move forward while we build the image
      allow(Time).to receive(:now).and_return(Time.at(1_526_533_532))
      # but the timestamp should be the same here
      expect(subject.tag).to eq("#{git_sha}_20150316191852")
    end

    describe "#full_tag" do
      it "is the repo plus the tag" do
        expect(subject.full_tag).to eq "#{subject.repo}:#{subject.tag}"
      end
    end
  end

  describe "#name" do
    it "uses the name from the data" do
      expect(subject.name).to eq "The Worlds Best Webapp II"
    end
  end

  describe "#build" do
    it "calls the builder" do
      expect(subject.builder).to receive(:build)
      subject.build
    end
  end

  describe "#push" do
    let(:image) { double(info: { "RepoTags" => ["#{subject.repo}:#{subject.tag}"] }) }

    before do
      ENV["DOCKERCFG"] = "{\"https://index.docker.io/v1/\":{\"auth\":\"ZXJybTpwYXNzd29yZA\",\"email\":\"ed@reevoo.com\"}}" # rubocop:disable Metrics/LineLength
      allow(subject.builder).to receive(:build).and_return(image)
      subject.build
    end

    it "pushes the tagged image to the repo" do
      expect(Docker).to receive(:authenticate!).with(
        "email" => "ed@reevoo.com",
        "username" => "errm",
        "password" => "password",
        "serveraddress" => "https://index.docker.io/v1/",
      )
      expect(image).to receive(:push)
      subject.push
    end

    context "without a repo" do
      let(:data) do
        {
          "application" => {
            "name" => "The Worlds Best Webapp II",
          },
          "build" => { "builder" => "Dockerfile" },
        }
      end

      it "does not push the local image" do
        expect(subject.repo).to eq "the_worlds_best_webapp_ii"
        subject.push
      end
    end
  end
end
