require 'fileutils'
require 'git_repo'
require 'tmpdir'

class GitCache
  def initialize(git_url)
    @git_url = git_url
  end

  def refresh
    if Dir.exist? File.join(git_url.cache_path, '.git')
      fetch
    else
      clone
    end
  end

  def make_working_copy
    Dir.mktmpdir do |dir|
      refresh
      system "cp -rp #{git_url.cache_path} #{dir}"
      FileUtils.rm_r File.join("#{dir}/.git"), force: true, secure: true
      yield "#{dir}/#{git_url.repo}"
    end
  end

  private

  attr_reader :git_url

  def clone
    FileUtils.mkdir_p git_url.cache_path
    GitRepo.clone(git_url.url, git_url.cache_path)
  end

  def fetch
    GitRepo.new(git_url.cache_path).pull
  end
end
