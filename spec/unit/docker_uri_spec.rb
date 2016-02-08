require "spec_helper"
require "docker_uri"

describe DockerURI do
  subject(:uri) { described_class.new(string) }

  context "a simple docker hub uri" do
    let(:string) { "ubuntu" }

    it "has a image" do
      expect(uri.image).to eq "ubuntu"
    end

    it "has a tag of latest" do
      expect(uri.tag).to eq "latest"
    end

    it "has a nil repo" do
      expect(uri.repo).to be_nil
    end

    it "has a nil registry" do
      expect(uri.registry).to be_nil
    end
  end

  context "a docker hub uri with a tag" do
    let(:string) { "ubuntu:14.04" }

    it "has a image" do
      expect(uri.image).to eq "ubuntu"
    end

    it "has a tag of 14.04" do
      expect(uri.tag).to eq "14.04"
    end

    it "has a nil repo" do
      expect(uri.repo).to be_nil
    end

    it "has a nil registry" do
      expect(uri.registry).to be_nil
    end
  end

  context "a docker hub uri with a repo and tag" do
    let(:string) { "assemblyline/ubuntu:14.04" }

    it "has a image" do
      expect(uri.image).to eq "ubuntu"
    end

    it "has a tag of 14.04" do
      expect(uri.tag).to eq "14.04"
    end

    it "has a repo of assemblyline" do
      expect(uri.repo).to eq "assemblyline"
    end

    it "has a nil registry" do
      expect(uri.registry).to be_nil
    end
  end

  context "a quay uri with a repo and tag" do
    let(:string) { "quay.io/assemblyline/ubuntu:14.04" }

    it "has a image" do
      expect(uri.image).to eq "ubuntu"
    end

    it "has a tag of 14.04" do
      expect(uri.tag).to eq "14.04"
    end

    it "has a repo of assemblyline" do
      expect(uri.repo).to eq "assemblyline"
    end

    it "has a the registry" do
      expect(uri.registry).to eq "quay.io"
    end
  end
end
