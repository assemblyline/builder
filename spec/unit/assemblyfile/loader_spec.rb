require 'assemblyfile/loader'

describe Assemblyfile do
  subject { described_class.load(File.expand_path("../../../fixtures/dockerfile_project", __FILE__)) }

  it 'loads the Assemblyfile in the given dir' do
    expect(subject.size).to eq 1
  end

  it 'uses the correct builder' do
    expect(subject.first.builder.class).to eq Builder::Dockerfile
  end

  it 'has the correct name' do
    expect(subject.first.name).to eq 'Fast Awesome API'
  end
end
