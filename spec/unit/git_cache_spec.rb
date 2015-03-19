require 'spec_helper'
require 'git_cache'

describe GitCache do
  let(:cache_path) { Dir.mktmpdir }
  let(:git_url) { double(cache_path: cache_path, url: 'foo-url', repo: 'foo') }
  subject { described_class.new git_url }

  after do
    FileUtils.rm_rf cache_path
  end

  describe '#refresh' do
    it 'creates the cache if it does not exist' do
      allow(Dir).to receive(:exist?).with(cache_path)
      expect(FileUtils).to receive(:mkdir_p).with(cache_path)
      expect(GitRepo).to receive(:clone).with('foo-url', cache_path, mirror: true)
      subject.refresh
    end

    it 'fetches the cache if it does exist' do
      allow(Dir).to receive(:exist?).with(cache_path).and_return(true)
      git = double
      expect(GitRepo).to receive(:new).with(cache_path).and_return(git)
      expect(git).to receive(:fetch)
      subject.refresh
    end
  end

  describe '#make_working_copy' do
    let!(:git_sha) do
      sha = ''
      MiniGit::Capturing.init cache_path, bare: true
      Dir.mktmpdir do |dir|
        MiniGit::Capturing.git :clone, cache_path, dir
        FileUtils.touch("#{dir}/file.txt")
        git = MiniGit::Capturing.new(dir)
        git.add '.'
        git.commit m: 'test commit'
        sha = git.rev_parse({ short: true }, :HEAD).chomp
        git.push
      end
      sha
    end

    let(:tmp_dir) do
      Dir.mktmpdir
    end

    after do
      FileUtils.rm_rf tmp_dir
    end

    it 'refreshes the code' do
      expect(subject).to receive(:refresh)
      allow(subject).to receive(:system)
      subject.make_working_copy {}
    end

    it 'clones the code into place' do
      expect(Dir).to receive(:mktmpdir).and_yield(tmp_dir)
      allow(subject).to receive(:refresh)
      expect(GitRepo).to receive(:clone).and_call_original do |from, to|
        expect(from).to eq cache_path
        expect(to).to eq "#{tmp_dir}/foo"
      end
      subject.make_working_copy {}
    end

    it 'yields the tmpdir' do
      expect(Dir).to receive(:mktmpdir).and_yield(tmp_dir)
      allow(subject).to receive(:refresh)
      subject.make_working_copy do |dir, sha|
        expect(sha).to eq git_sha
        expect(dir).to eq File.join(tmp_dir, 'foo')
      end
    end
  end
end
