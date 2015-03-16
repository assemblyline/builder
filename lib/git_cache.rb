require 'fileutils'
require 'git_repo'
require 'tmpdir'

class GitCache
  def self.refresh(git_url)
    new(git_url).refresh
  end

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

  def make_working_copy
    Dir.mktmpdir do |dir|
      refresh
      system "cp -rp #{git_url.cache_path} #{dir}"
      yield "#{dir}/#{git_url.repo}"
    end
  end

  private

  attr_reader :git_url

  def clone
    FileUtils.mkdir_p git_url.cache_path
    GitRepo.clone git_url.url, git_url.cache_path
  end

  def fetch
    GitRepo.new(git_url.cache_path).pull
  end
end
