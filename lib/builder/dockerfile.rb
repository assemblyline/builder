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

    def build(opts = {})
      set_read_timeout
      image = Docker::Image.build_from_dir(path, opts.merge("pull" => true)) { |chunk| format_build_status(chunk) }
      image.tag("repo" => application.repo, "tag" => application.tag, "force" => true)
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
  end
end
