require 'fileutils'
require 'git_repo'
require 'tmpdir'

class GitCache
  def initialize(git_url)
    @git_url = git_url
  end

  def refresh
    if Dir.exist? git_url.cache_path
      fetch
    else
      clone
    end
  end

  def make_working_copy(branch: branch)
    Dir.mktmpdir do |dir|
      workdir = File.join(dir, git_url.repo)
      refresh
      GitRepo.clone(git_url.cache_path, workdir)
      merge(branch, workdir) if branch
      sha = GitRepo.new(workdir).sha
      FileUtils.rm_r File.join(workdir, '.git'), force: true, secure: true
      yield workdir, sha
    end
  end

  private

  attr_reader :git_url

  def clone
    FileUtils.mkdir_p git_url.cache_path
    GitRepo.clone(git_url.url, git_url.cache_path, mirror: true)
  end

  def fetch
    GitRepo.new(git_url.cache_path).fetch
  end

  def merge(ref, dir)
    GitRepo.new(dir).merge(ref)
  end
end
