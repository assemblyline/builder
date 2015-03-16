require 'docker'

class Builder
  class Dockerfile
    def initialize(application:, build:)
      self.application = application
      self.repo = build['repo']
    end

    def build
      system "docker build -t #{repo}:#{tag} #{application.path}"
    end

    def push
      auth_docker
      Docker::Image.get("#{repo}:#{tag}").push { |s| puts JSON.parse(s)['status'] }
    end

    protected

    attr_accessor :application, :repo

    private

    def tag
      @_tag ||= `git --git-dir=#{git_dir} rev-parse --short HEAD`.chomp + '_' + Time.now.strftime('%Y%m%d%H%M%S')
    end

    def git_dir
      File.join(application.path, '.git')
    end

    def auth_docker
      Docker.authenticate!(
        'username' => ENV['DOCKER_USERNAME'],
        'password' => ENV['DOCKER_PASSWORD'],
        'serveraddress' => ENV['DOCKER_REPO_ADDR']
      )
    end
  end
end
