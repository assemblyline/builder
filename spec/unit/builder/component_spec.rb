require 'spec_helper'
require 'builder/component'

describe Builder::Component do
  subject { described_class.new(component: component, versions: versions) }
  let(:component) { double(path: 'foo') }
  let(:versions) { double }

  let(:version1) { double }
  let(:version2) { double }

  before do
    allow(Builder::Component::Version).to receive(:versions)
      .with(component: component, versions: versions)
      .and_return([version1, version2])
  end

  describe '#build' do
    it 'calls build on each version and returns the result to the caller' do
      expect(version1).to receive(:build).and_return('foo')
      expect(version2).to receive(:build).and_return('bar')
      expect(subject.build).to eq %w(foo bar)
    end
  end

end
