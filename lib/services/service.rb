require "docker"
require "colorize"
require "log"
require "docker_stream_logger"

module Services
  class Service
    def initialize(application:, data:)
      self.application = application
      self.data = data
    end

    def start
      pull_image_if_required
      self.container ||= Docker::Container.create(
        "Image" => image,
        "Cmd" => command,
        "Env" => service_env.map { |var, val| "#{var}=#{val}" },
      )
      Log.out.puts "starting #{service_name} service".bold.green
      container.start
    end

    def env
      {}
    end

    def service_env
      {}
    end

    def stop
      Log.out.puts "stopping #{service_name} service".bold.green
      if container
        container.delete(force: true)
      else
        Log.err.puts "could not stop #{service_name} service, It may have never started".bold.red
      end
    end

    protected

    attr_accessor :application, :data, :container

    private

    def command
      nil
    end

    def service_name
      self.class.name.split("::").last.downcase
    end

    def image
      "#{service_name}:#{version}"
    end

    def version
      data["version"] || "latest"
    end

    def pull_image_if_required
      Docker::Image.get(image)
    rescue Docker::Error::NotFoundError
      pull_image
    end

    def pull_image
      logger = DockerStreamLogger.new
      Docker::Image.create("fromImage" => image) do |stream|
        logger.log(stream)
      end
    rescue Docker::Error::NotFoundError
      Docker::Image.get(image)
    end

    def ip
      @ip ||= container.json["NetworkSettings"]["IPAddress"]
    end
  end
end
