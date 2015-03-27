require 'services/service'
require 'colorize'

module Services
  class Postgres < Service
    def start
      super
      wait
      create_database
    end

    def env
      { 'DATABASE_URL' => database_url }
    end

    protected

    attr_accessor :application, :data, :container

    private

    def database_url
      "postgres://postgres@#{ip}/#{database_name}"
    end

    def create_database
      print "creating #{database_name} postgres database".bold.green
      create_database_with_retry
      puts
    end

    def create_database_with_retry
      _out, _err, status = container.exec(['psql', '-U', 'postgres', '-c', "CREATE DATABASE #{database_name};"])
      return unless status == 2
      print '.'
      sleep 0.1
      create_database_with_retry
    end

    def database_name
      data['database_name'] || "#{application.name.downcase.split.join('_')}_test"
    end

    def wait
      print 'waiting for postgres service to be up =>'.bold.green
      container.exec([
        'bash',
        '-c',
        "while [ ! -S /var/run/postgresql/.s.PGSQL.5432 ]; do echo '.'; sleep 0.1; done",
      ]) { print '.' }
      puts
    end
  end
end
