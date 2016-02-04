require "spec_helper"
require "assemblyfile/loader"

describe Assemblyfile do
  let(:sha) { "dfighyjdfh" }
  subject { described_class.load(assemblyfile_path, sha) }

  describe "loading an application" do
    let(:assemblyfile_path) { "spec/fixtures/dockerfile_project" }

    it "loads the Assemblyfile in the given dir" do
      expect(subject.size).to eq 1
    end

    it "loads an application" do
      expect(subject.first).to be_a Application
    end

    it "uses the correct builder" do
      expect(subject.first.builder.class).to eq Builder::Dockerfile
    end

    it "has the correct name" do
      expect(subject.first.name).to eq "Fast Awesome API"
    end
  end

  describe "loading a component" do
    let(:assemblyfile_path) { "spec/fixtures/components/simple_component" }

    it "loads the Assemblyfile in the given dir" do
      expect(subject.size).to eq 1
    end

    it "loads a component" do
      expect(subject.first).to be_a Component
    end

    it "uses the correct builder" do
      expect(subject.first.builder.class).to eq Builder::Component
    end

    it "has the correct name" do
      expect(subject.first.name).to eq "Test Component"
    end
  end
end
