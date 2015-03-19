require 'spec_helper'
require 'git_cache'

describe GitCache do
  let(:git_url) { double(cache_path: 'cache/github.com/bar/foo', url: 'foo-url', repo: 'foo') }
  subject { described_class.new git_url }

  describe '#refresh' do
    it 'creates the cache if it does not exist' do
      allow(Dir).to receive(:exist?).with('cache/github.com/bar/foo/.git')
      expect(FileUtils).to receive(:mkdir_p).with('cache/github.com/bar/foo')
      expect(GitRepo).to receive(:clone).with('foo-url', 'cache/github.com/bar/foo')
      subject.refresh
    end

    it 'fetches the cache if it does exist' do
      allow(Dir).to receive(:exist?).with('cache/github.com/bar/foo/.git').and_return(true)
      git = double
      expect(GitRepo).to receive(:new).with('cache/github.com/bar/foo').and_return(git)
      expect(git).to receive(:pull)
      subject.refresh
    end
  end

  describe '#make_working_copy' do
    it 'refreshes the code' do
      expect(subject).to receive(:refresh)
      allow(subject).to receive(:system)
      subject.make_working_copy {}
    end

    it 'copies the code into place' do
      expect(Dir).to receive(:mktmpdir).and_yield('/tmp/23rg526t3u')
      allow(subject).to receive(:refresh)
      expect(subject).to receive(:system) do |command|
        expect(command).to eq 'cp -rp cache/github.com/bar/foo /tmp/23rg526t3u'
      end
      subject.make_working_copy {}
    end

    it 'yields the tmpdir' do
      expect(Dir).to receive(:mktmpdir).and_yield('/tmp/23rg526t3u')
      allow(subject).to receive(:refresh)
      allow(subject).to receive(:system)
      subject.make_working_copy do |dir|
        expect(dir).to eq '/tmp/23rg526t3u/foo'
      end
    end
  end
end
