require 'git_url'
require 'git_cache'
require 'tmpdir'
require 'assemblyfile/loader'

class Builder
  def initialize(url:, branch: nil)
    @url = GitUrl.new url
    @path = path
    @branch = branch
  end

  def build
    GitCache.refresh url
    Dir.mktmpdir do |dir|
      system "cp -rp #{url.cache_path}/* #{dir}"
      Dir.chdir dir
      system "git merge #{branch}" if branch
      Assemblyfile.load(dir).each do |application|
        application.builder.build
      end
      # Submit Docker Tag to shipping agent and push image
    end
  end

  private

  attr_reader :url, :path, :branch

end
