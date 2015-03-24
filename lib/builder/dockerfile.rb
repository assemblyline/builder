require 'docker'
require 'patch/rubygems'

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
        $stderr.puts json['error']
        exit 1
      end
      puts json['stream']
    end
  end
end
