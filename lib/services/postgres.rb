require 'docker'

module Services
  class Postgres
    def initialize(application:, data:)
      self.application = application
      self.data = data
    end

    def start
      pull_image_if_required
      self.container ||= Docker::Container.create('Image' => image)
      container.start
      wait
      create_database
    end

    def env
      { "DATABASE_URL" => database_url }
    end

    def stop
      container.delete(force: true)
    end

    protected

    attr_accessor :application, :data, :container

    private

    def pull_image_if_required
      Docker::Image.get(image)
    rescue Docker::Error::NotFoundError
      Docker::Image.create('fromImage' => image) { |c| print c }
    end

    def image
      "postgres:#{version}"
    end

    def version
      data['version'] || 'latest'
    end

    def database_url
      "postgres://postgres@#{ip}/#{database_name}"
    end

    def create_database
      container.exec(["psql", "-U", "postgres" , "-c", "CREATE DATABASE #{database_name};"])
    end

    def database_name
      data['database_name'] || "#{application.name.downcase.split.join('_')}_test"
    end

    def wait
      container.exec(["bash", "-c", "while [ ! -S /var/run/postgresql/.s.PGSQL.5432 ]; do sleep 0.1; done"])
    end

    def ip
      container.json["NetworkSettings"]["IPAddress"]
    end
  end
end
