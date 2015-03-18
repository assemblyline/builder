require 'spec_helper'
require 'git_repo'

describe GitRepo do
  subject { described_class.new(Dir.pwd) }
  let(:short_sha) { `git rev-parse --short HEAD`.chomp }

  describe '#sha' do
    it 'returns a shortend version of the head commit' do
      expect(subject.sha).to eq short_sha
    end
  end

  describe '#pull' do
    it 'calls the MiniGit pull method' do
      git = double
      allow(MiniGit).to receive(:new).with(Dir.pwd).and_return(git)
      expect(git).to receive(:pull)
      subject.pull
    end
  end

  describe '.clone' do
    it 'calls the MiniGit clone method' do
      expect(MiniGit).to receive(:git).with(:clone, 'f0000','B4arr')
      described_class.clone 'f0000', 'B4arr'
    end
  end
end
