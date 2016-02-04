require "services/service"
require "colorize"
require "log"

module Services
  class Mysql < Service
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

    def service_env
      {
        "MYSQL_ALLOW_EMPTY_PASSWORD" => true,
      }
    end

    def user
      "conan"
    end

    def password
      "sekret"
    end

    def database_url
      "mysql2://root@#{ip}/#{database_name}"
    end

    def create_database
      Log.out.print "creating #{database_name} mysql database".bold.green
      create_database_with_retry
      Log.out.puts
    end

    def create_database_with_retry
      _out, _err, status = container.exec(["mysql", "--user=root", "-h", ip, "-e", "CREATE DATABASE #{database_name};"])
      return if status == 0
      Log.out.print "."
      sleep 0.1
      create_database_with_retry
    end

    def database_name
      data["database_name"] || "#{application.name.downcase.split.join("_")}_test"
    end
  end
end
