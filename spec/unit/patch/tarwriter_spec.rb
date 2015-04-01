require 'spec_helper'
require 'patch/tarwriter'

describe Gem::Package::TarWriter do
  let(:tarfile) { StringIO.new }

  it 'sets the mtime to 1 in the tar headers' do
    described_class.new(tarfile) do |tar|
      tar.add_file_simple('foo.txt', 33_188, 4) do |tar_file|
        IO.copy_stream(StringIO.new("bar\n"), tar_file)
      end
      tar.add_file_simple('bar.txt', 33_188, 4) do |tar_file|
        IO.copy_stream(StringIO.new("foo\n"), tar_file)
      end
    end

    tarfile.rewind

    Gem::Package::TarReader.new tarfile do |tar|
      tar.each do |tarfile|
        expect(tarfile.header.mtime).to eq 1
      end
    end
  end
end
