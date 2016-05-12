require "docker"
require "patch/tarwriter"
require "docker_stream_logger"

class Builder
  class Dockerfile
    def initialize(application:, build: nil, path: nil) # rubocop:disable Lint/UnusedMethodArgument
      self.application = application
      self.path = path || application.path
      self.log = DockerStreamLogger.new
    end

    def build(pushable = false)
      set_read_timeout
      prepare_cache if pushable
      image = Docker::Image.build_from_dir(path, "pull" => true) { |chunk| format_build_status(chunk) }
      image.tag("repo" => application.repo, "tag" => application.tag, "force" => true)
      image.tag("repo" => application.repo, "tag" => "cache", "force" => true)
      image
    end

    protected

    attr_accessor :application, :path, :log

    def set_read_timeout
      Excon.defaults[:read_timeout] = 1000
    end

    def format_build_status(chunk)
      log.log(chunk)
    end

    def prepare_cache
      local_cache || pull_cache
    end

    def local_cache
      Docker::Image.get("#{application.repo}:cache")
      Log.out.puts("using local cache for #{application.repo}")
      true
    rescue Docker::Error::NotFoundError
      Log.out.puts("no local cache for #{application.repo}")
      false
    end

    def pull_cache
      Docker::Image.create("fromImage" => "#{application.repo}:cache")
      Log.out.puts("restored cache for #{application.repo}")
    rescue Docker::Error::DockerError => e
      Log.out.puts(e.inspect)
      Log.out.puts("cache for #{application.repo} was not restored")
    end
  end
end
