require 'spec_helper'
require 'builder/component/template'

describe Builder::Component::Template do
  let(:path) { 'spec/fixtures/components/simple_component/templates/0.0.1/ONE.erb' }
  let(:output_path) { '/foo/bar/whatever' }
  subject { described_class.new(path: path, output: output_path) }

  describe '#write_config' do
    it 'writes the config to the output path' do
      # this is here so it is on the binding
      data = { 'hello' => 'world' } # rubocop:disable Lint/UselessAssignment
      expect(File).to receive(:write).with(output_path, "world\n")
      subject.write_config(binding)
    end
  end

  describe '#==' do
    it 'is equal when the output and path are the same' do
      expect(subject).to eq described_class.new(output: output_path, path: path)
    end

    it 'is not equal if the output_path differs' do
      expect(subject).to_not eq described_class.new(output: '/some/other', path: path)
    end

    it 'is not equal if the path differs' do
      expect(subject).to_not eq described_class.new(output: output_path, path: '/other/template.erb')
    end

    it 'is not equal if both paths differ' do
      expect(subject).to_not eq described_class.new(output: '/some/other', path: '/other/template.erb')
    end
  end
end
