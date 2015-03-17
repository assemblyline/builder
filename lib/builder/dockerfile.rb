require 'docker'
require 'git_repo'

class Builder
  class Dockerfile
    def initialize(application:, build:)
      self.application = application
    end

    def build
      system "docker build -t #{application.tag} #{application.path}"
    end

    protected

    attr_accessor :application

  end
end
