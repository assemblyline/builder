require 'git_url'
require 'git_cache'
require 'tmpdir'
require 'assemblyfile/loader'

class Builder
  def initialize(url:)
    @url = GitUrl.new url
    @path = path
    @branch = branch
  end

  def build
    Dir.mktmpdir do |dir|
      cache.make_working_copy(dir)
      Assemblyfile.load(dir).each do |application|
        application.builder.build
      end
      # Submit Docker Tag to shipping agent and push image
    end
  end

  private

  def cache
    GitCache.new(url)
  end

  attr_reader :url, :path, :branch

end
