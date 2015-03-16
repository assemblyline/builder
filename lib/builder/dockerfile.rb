require 'docker'
require 'git_repo'

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
      @_tag ||= sha + '_' + Time.now.strftime('%Y%m%d%H%M%S')
    end

    def sha
      GitRepo.new(application.path).sha
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
