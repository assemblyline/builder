require 'colorize'
require 'docker'

class Builder
  class NodeJS
    def initialize(application:, build:)
      self.application = application
      self.script = build['script']
    end

    def build
      container
      thread = Thread.new { attach }
      container.start
      thread.join
      puts exit_code
      require 'pry'
      binding.pry
      exit exit_code
    end

    protected

    attr_accessor :application, :script

    private

    def exit_code
      container.json["State"]["ExitCode"]
    end

    def container
      @_container ||= Docker::Container.create('Cmd' => command, 'Image' => 'quay.io/assemblyline/nodejs:0.10.36', 'Volumes' => { '/tmp2' => {} })
    end

    def command
      ["bash", "-c", script.join(" && ")]
    end

    def attach
      container.attach do |stream, chunk|
        printf "#{stream}: ".red if stream != :stdout
        puts chunk
      end
    end
  end
end
