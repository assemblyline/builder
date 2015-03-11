require 'docker'

class Builder
  class Dockerfile
    def initialize(application:, build:)
      self.application = application
      self.repo = build['repo']
    end

    def build
      system "docker build #{application.path}"
    end

    protected

    attr_accessor :application, :repo
  end
end
