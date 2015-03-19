require 'spec_helper'
require 'mtime'
require 'tmpdir'
require 'fileutils'

describe Mtime do
  describe '.clobber' do
    it 'clobbers the mtime of everything in the dir' do
      Dir.mktmpdir do |dir|
        FileUtils.touch "#{dir}/foo"
        FileUtils.touch "#{dir}/bar"
        FileUtils.mkdir_p "#{dir}/foo-bar"
        FileUtils.touch "#{dir}/foo-bar/baz.something"

        Mtime.clobber(dir)

        expect(File.new("#{dir}/foo").mtime).to eq Time.at(1)
        expect(File.new("#{dir}/bar").mtime).to eq Time.at(1)
        expect(File.new("#{dir}/foo-bar").mtime).to eq Time.at(1)
        expect(File.new("#{dir}/foo-bar/baz.something").mtime).to eq Time.at(1)
      end
    end
  end
end
