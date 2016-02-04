require "spec_helper"
require "dir_cache"

describe DirCache do
  describe "#save and #prime" do
    before do
      tmpdir = Dir.mktmpdir
      File.write(File.join(tmpdir, "package.json"), "example config file")
      FileUtils.mkdir(File.join(tmpdir, "node_modules"))
      File.write(File.join(tmpdir, "node_modules", "foo.txt"), "cached file")
      described_class.new(path: tmpdir, config: "package.json", dirname: "node_modules").save
      FileUtils.rm_rf tmpdir
    end

    subject { described_class.new(path: appdir, config: "package.json", dirname: "node_modules") }
    let(:appdir) { Dir.mktmpdir }

    context "when the config file has the same content" do
      before do
        File.write(File.join(appdir, "package.json"), "example config file")
      end

      it "restores the cached file" do
        subject.prime
        expect(File.read(File.join(appdir, "node_modules", "foo.txt"))).to eq "cached file"
      end
    end

    context "when the config file has the diferent content" do
      before do
        File.write(File.join(appdir, "package.json"), "example config file v2")
      end

      it "does not restore the cached file" do
        subject.prime
        expect(File.exist?(File.join(appdir, "node_modules", "foo.txt"))).to be_falsey
      end
    end
  end
end
