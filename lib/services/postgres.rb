require "services/service"
require "colorize"
require "log"

module Services
  class Postgres < Service
    def start
      super
      create_database
    end

    def env
      { "DATABASE_URL" => database_url }
    end

    protected

    attr_accessor :application, :data, :container

    private

    def database_url
      "postgres://postgres@#{ip}/#{database_name}"
    end

    def create_database
      Log.out.print "creating #{database_name} postgres database".bold.green
      create_database_with_retry
      Log.out.puts
    end

    def create_database_with_retry
      _out, _err, status = container.exec(["psql", "-U", "postgres", "-c", "CREATE DATABASE #{database_name};"])
      return unless status == 2
      Log.out.print "."
      sleep 0.1
      create_database_with_retry
    end

    def database_name
      data["database_name"] || "#{application.name.downcase.split.join("_").tr("-", "_")}_test"
    end
  end
end
