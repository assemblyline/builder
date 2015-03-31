require 'git_url'
require 'git_cache'
require 'tmpdir'
require 'assemblyfile/loader'

class Builder

  def self.load_builder(application: application, build: build)
    name = build['builder']
    require "builder/#{name.downcase}"
    const_get(
      constants.detect { |c| c.to_s.downcase == name.downcase },
    ).new(application: application, build: build)
  end

  def self.local_build(dir: dir, sha:, push: false)
    Dir.mktmpdir do |tmpdir|
      FileUtils.cp_r(dir + '/.', tmpdir, preserve: true)
      Assemblyfile.load(tmpdir, sha).each do |application|
        application.build
        application.push if push
      end
    end
  end

  def initialize(url:, branch: nil)
    @url = GitUrl.new url
    @path = path
    @branch = branch
  end

  def build(push: false)
    cache.make_working_copy(branch: branch) do |dir, sha|
      Assemblyfile.load(dir, sha).each do |assembly|
        assembly.build
        assembly.push if push
      end
    end
  end

  private

  def cache
    GitCache.new(url)
  end

  attr_reader :url, :path, :branch

end
