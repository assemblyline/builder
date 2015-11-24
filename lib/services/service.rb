require 'docker'
require 'colorize'
require 'log'
require 'features'

module Services
  class Service
    def initialize(application:, data:)
      self.application = application
      self.data = data
    end

    def start
      pull_image_if_required
      self.container ||= Docker::Container.create(
        'Image' => image,
        'Cmd' => command,
        'Env' => service_env.map { |var,val| "#{var}=#{val}" },
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
      container.delete(force: true) if Features.kill?
    end

    protected

    attr_accessor :application, :data, :container

    private

    def command
      nil
    end

    def service_name
      self.class.name.split('::').last.downcase
    end

    def image
      "#{service_name}:#{version}"
    end

    def version
      data['version'] || 'latest'
    end

    def pull_image_if_required
      Docker::Image.get(image)
    rescue Docker::Error::NotFoundError
      Log.out.puts "pulling #{service_name} version #{version}".bold.green
      Docker::Image.create('fromImage' => image) { Log.out.print '.' }
    end

    def ip
      container.json['NetworkSettings']['IPAddress']
    end
  end
end
