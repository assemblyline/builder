require 'fileutils'
require 'digest/sha1'
require 'tmpdir'
require 'colorize'

class DirCache
  def initialize(path:, config:, dirname:)
    self.path    = path
    self.config  = config
    self.dirname = dirname
  end

  def prime
    return unless config?
    puts "priming #{dirname} cache from #{cache_path}".bold.green
    copy(cache_path, install_path)
  end

  def save
    return unless config?
    puts "saving #{dirname} cache to #{cache_path}".bold.green
    copy(install_path, cache_path)
  end

  protected

  attr_accessor :path, :config, :dirname

  private

  def copy(from, to)
    return unless File.directory?(from)
    FileUtils.rm_rf(to)
    FileUtils.mkdir_p(to)
    FileUtils.cp_r("#{from}/.", to)
  end

  def config?
    File.exist?(File.join(path, config))
  end

  def install_path
    File.join(path, dirname)
  end

  def cache_path
    File.join(
      Dir.tmpdir,
      'assemblyline',
      "#{dirname}_cache",
      Digest::SHA1.hexdigest(File.read(File.join(path, config))),
    )
  end
end
