# This is a nasty hack to get around
# the docker cache busting when the mtime
# changes
#
# If we clobber the mtime to some consistent
# value then the cache should invalidate based
# on content, docker may be adding an option
# to fix this https://github.com/docker/docker/issues/4351
# if that gets done we should use that insted of this
class Mtime
  CLOBBER_TIME = Time.at(1)

  def self.clobber(path)
    Dir.glob(File.join(path, "**/**"), File::FNM_DOTMATCH).each do |p|
      clobber_file p
    end
  end

  private

  def self.clobber_file(p)
    File.utime(CLOBBER_TIME, CLOBBER_TIME, p)
  rescue Errno::ENOENT => e
    $stderr.puts "WARN mtime clobber failed for #{p} with: #{e.message}"
  end
end
