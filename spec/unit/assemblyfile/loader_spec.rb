require 'assemblyfile/loader'

describe Assemblyfile do
  it 'loads the Assemblyfile in the given dir' do
    require 'pry'
    foo = described_class.load(File.expand_path("../../../fixtures/dockerfile_project", __FILE__))
    binding.pry
  end
end
