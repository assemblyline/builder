require 'docker'

class Builder
  class Dockerfile
    def initialize(application:, build:)
      self.application = application
      self.repo = build['repo']
    end

    def build
      puts 'this should do something'
      binding.pry
      d = Docker::Image.build_from_dir(application.path)
    end

    protected

    attr_accessor :application, :repo
  end
end
