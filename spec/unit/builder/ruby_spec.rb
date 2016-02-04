require "builder/ruby"

describe Builder::Ruby do
  let(:application) { double(path: "spec/fixtures/ruby_projects/ruby_version_app") }
  let(:build) { {} }

  subject { described_class.new(application: application, build: build) }

  describe "ruby version detection" do
    it "reads the version from the .ruby-version file" do
      expect(subject.send(:ruby_version)).to eq "2.2.3"
    end

    context "when a version is set in the Assemblyfile" do
      let(:build) { { "version" => "2.1.7" } }

      it "wins" do
        expect(subject.send(:ruby_version)).to eq "2.1.7"
      end
    end

    context "when there is no ruby version set anywhere" do
      let(:application) { double(path: "spec/fixtures/ruby_projects/no_version_app") }

      it "defaults to the latest version" do
        expect(subject.send(:ruby_version)).to eq "latest"
      end
    end
  end
end
