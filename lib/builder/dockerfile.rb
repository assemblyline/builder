require 'docker'
require 'git_repo'
require 'mtime'

class Builder
  class Dockerfile
    def initialize(application:, build:) # rubocop:disable Lint/UnusedMethodArgument
      self.application = application
    end

    def build
      Mtime.clobber(application.path)
      system "docker build -t #{application.full_tag} #{application.path}"
    end

    protected

    attr_accessor :application

  end
end
