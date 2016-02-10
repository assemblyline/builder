require "spec_helper"
require "docker_stream_logger"
require "fixtures/docker_streams"

describe DockerStreamLogger do
  let(:output) { Log.out.string.split("\n") }

  context "Pulling an image from the registry" do
    before { stream_fixture(DockerStreamFixtures::IMAGE_PULL) }

    it "Prints a message before pulling the image" do
      expect(output.first).to eq "Pulling from assemblyline/builder-frontendjs:0.12.0".bold.green
    end

    it "formats a progress bar when downloading an image" do
      expect(output[3]).to eq "Downloading Image: |===========================================================|"
    end

    it "Prints a message when the download is done" do
      expect(output.last).to eq "Status: Downloaded newer image for quay.io/assemblyline/builder-frontendjs:0.12.0".bold.green
    end
  end

  context "Building a Dockerfile where the image has allready been pulled" do
    before { stream_fixture(DockerStreamFixtures::DOCKERFILE_PULLED) }

    it "outputs the stream as is" do
      expect(output.first).to eq "Step 1 : FROM quay.io/assemblyline/ubuntu:14.04.2"
      expect(output.last).to eq "Successfully built 2937fd860685"
    end

    it "formats the status info correctly" do
      expect(output[1]).to eq "Pulling from assemblyline/ubuntu:14.04.2".bold.green
      expect(output[2]).to eq "Digest: sha256:5ae07f4ea4e0adf0f86e9d703e2e783d1bbf4d76aaf06092fb1bce3e625ad7bf".bold.green
      expect(output[3]).to eq "Status: Image is up to date for quay.io/assemblyline/ubuntu:14.04.2".bold.green
    end
  end

  context "Building a Dockerfile where the image has not allready been pulled" do
    before { stream_fixture(DockerStreamFixtures::DOCKERFILE_PULL) }

    it "outputs the stream as is" do
      expect(output.first).to eq "Step 1 : FROM quay.io/assemblyline/ubuntu:14.04.2"
      expect(output.last).to eq "Successfully built 8e5259c1f15a"
    end

    it "formats a progress bar when downloading the image" do
      expect(output[1]).to eq "Pulling from assemblyline/ubuntu:14.04.2".bold.green
      expect(output[4]).to eq "Downloading Image: |===========================================================|"
      expect(output[5]).to eq "Digest: sha256:5ae07f4ea4e0adf0f86e9d703e2e783d1bbf4d76aaf06092fb1bce3e625ad7bf".bold.green
      expect(output[6]).to eq "Status: Downloaded newer image for quay.io/assemblyline/ubuntu:14.04.2".bold.green
    end
  end

  context "Where there is an error" do
    it "logs to stdout and exits" do
      expect do
        stream_fixture([{ "error" => "stuff is broken" }])
      end.to raise_error(SystemExit)
      expect(Log.err.string).to eq "stuff is broken\n"
    end
  end

  def stream_fixture(fixture)
    fixture.each do |chunk|
      subject.log(JSON.dump(chunk))
    end
  end
end
