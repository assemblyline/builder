require 'spec_helper'
require 'git_repo'
require 'tmpdir'
require 'fileutils'

describe GitRepo do
  subject { described_class.new(Dir.pwd) }
  let(:short_sha) { `git rev-parse --short HEAD`.chomp }

  describe '#sha' do
    it 'returns a shortend version of the head commit' do
      expect(subject.sha).to eq short_sha
    end
  end

  describe '#fetch' do
    it 'calls the MiniGit fetch method' do
      git = double
      allow(MiniGit).to receive(:new).with(Dir.pwd).and_return(git)
      expect(git).to receive(:fetch)
      subject.fetch
    end
  end

  describe '.clone' do
    it 'calls the MiniGit clone method' do
      expect(MiniGit).to receive(:git).with(:clone, 'f0000', 'B4arr')
      described_class.clone 'f0000', 'B4arr'
    end
  end

  describe '.merge' do
    let(:working_dir) { Dir.mktmpdir }

    let(:git) { MiniGit::Capturing.new(working_dir) }

    subject { described_class.new(working_dir) }

    after { FileUtils.rm_rf working_dir }

    def setup(dir) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      MiniGit::Capturing.init dir
      FileUtils.touch File.join(dir, 'master')
      git.add('master')
      git.commit(m: 'commit on master branch')
      git.checkout(b: 'new-feature')
      FileUtils.touch File.join(dir, 'feature')
      git.add('feature')
      git.commit(m: 'commit on feature branch')
      @partial_sha = git.rev_parse({ short: true }, :HEAD).chomp
      FileUtils.touch File.join(dir, 'feature2')
      git.add('feature2')
      git.commit(m: 'second commit on feature branch')
      @final_sha = git.rev_parse({ short: true }, :HEAD).chomp
      git.checkout('master')
      FileUtils.touch File.join(dir, 'master2')
      git.add('master2')
      git.commit(m: 'another commit on master branch')
    end

    def check_state(files)
      files.each do |filename, expected|
        expect(File.exist?(File.join(working_dir, filename))).to eq expected
      end
    end

    it 'merges the specified branch into master' do
      setup(working_dir)

      check_state(
        'master'  =>  true,
        'master2' =>  true,
        'feature' => false,
        'feature2' => false,
      )

      subject.merge('new-feature')

      check_state(
        'master'  =>  true,
        'master2' =>  true,
        'feature' => true,
        'feature2' => true,
      )
    end

    it 'does not leave a working branch hanging around' do
      setup(working_dir)
      branch_count = git.branch.split("\n").count
      subject.merge('new-feature')
      expect(git.branch.split("\n").count).to eq branch_count
    end

    context 'merging by sha' do
      it 'only merges the branch up to the specified commit' do
        setup(working_dir)

        check_state(
          'master'  =>  true,
          'master2' =>  true,
          'feature' => false,
          'feature2' => false,
        )

        subject.merge(@partial_sha)

        check_state(
          'master'  =>  true,
          'master2' =>  true,
          'feature' =>  true,
          'feature2' => false,
        )
      end

      it 'can merge the whole branch' do
        setup(working_dir)

        check_state(
          'master'  =>  true,
          'master2' =>  true,
          'feature' => false,
          'feature2' => false,
        )

        subject.merge(@final_sha)

        check_state(
          'master'  =>  true,
          'master2' =>  true,
          'feature' =>  true,
          'feature2' => true,
        )
      end
    end
  end
end
