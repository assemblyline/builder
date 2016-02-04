require "spec_helper"
require "services/service"

describe Services::Service do
  subject { described_class.new(application: nil, data: nil) }
  describe "#env" do
    it "defaults to an empty hash" do
      expect(subject.env).to eq({})
    end
  end
end
