require 'spec_helper'
require 'builder/frontendjs'

describe Builder::FrontendJS do
  let(:application) { double(:application, path: '/tmp/foo/bah') }
  let(:build) { {} }

  subject { described_class.new(application: application, build: build) }


  let(:container) { double }

  before do
    allow(Docker::Container).to receive(:create).and_return(container)
  end

   it 'creates a docker container' do
    expect(Docker::Container).to receive(:create)
    subject
  end
end
