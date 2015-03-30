require 'docker'
require 'patch/rubygems'
require 'log'

class Builder
  class Dockerfile
    def initialize(application:, build: nil, path: nil) # rubocop:disable Lint/UnusedMethodArgument
      self.application = application
      self.path = path || application.path
    end

    def build
      image = Docker::Image.build_from_dir(path) { |chunk| format_build_status(chunk) }
      image.tag('repo' => application.repo, 'tag' => application.tag, 'force' => true)
      image
    end

    protected

    attr_accessor :application, :path

    def format_build_status(chunk)
      json = JSON.parse(chunk)
      if json['error']
        Log.err.puts json['error']
        exit 1
      end
      Log.out.puts json['stream'] if json['stream']
      Log.out.puts json['status'] if json['status']
    end
  end
end
