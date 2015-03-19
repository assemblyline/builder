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
    cache.make_working_copy do |dir, sha|
      Assemblyfile.load(dir, sha).each do |application|
        application.build
        application.push
      end
    end
  end

  private

  def cache
    GitCache.new(url)
  end

  attr_reader :url, :path, :branch

end
