require 'colorize'
require 'docker'
require 'builder/dockerfile'
require 'container_runner'
require 'dir_cache'

class Builder
  class FrontendJS
    def initialize(application:, build:)
      self.application = application
      self.script = build['script']
      self.target = File.join(application.path, build['target'] || 'dist')
      setup_build
    end

    def build
      run_build
      package_target
    end

    protected

    attr_accessor :application, :target, :container
    attr_writer :script

    private

    attr_accessor :caches

    def prime_cache
      self.caches = [
        DirCache.new(path: application.path, config: 'package.json', dirname: 'node_modules'),
        DirCache.new(path: application.path, config: 'bower.json', dirname: 'bower_components'),
      ]
      caches.each(&:prime)
    end

    def save_cache
      caches.each(&:save)
    end

    def setup_build
      prime_cache
      self.container = ContainerRunner.new(
        image: 'quay.io/assemblyline/builder-frontendjs',
        script: script,
        env: { 'SSH_KEY' => ENV['SSH_KEY'] },
      )
    end

    def run_build
      container.run
      save_cache
    end

    def package_target
      generate_dockerfile
      Dockerfile.new(application: application, path: target).build
    end

    def generate_dockerfile
      write '.dockerignore', "Dockerfile\n.dockerignore"
      write 'Dockerfile', "FROM nginx\nCOPY . /usr/share/nginx/html"
    end

    def write(_name, content)
      file = File.new(File.join(target, 'Dockerfile'), 'w')
      file.write content
      file.close
    end

    def script
      ["cd #{application.path}"] + (versions + (@script || npm + bower + grunt))
    end

    def grunt
      return [] unless grunt?
      ['grunt']
    end

    def grunt?
      exist? 'Gruntfile.js'
    end

    def npm
      return [] unless npm?
      ['npm install']
    end

    def npm?
      exist? 'package.json'
    end

    def bower
      return [] unless bower?
      ['bower install --allow-root']
    end

    def bower?
      exist? 'bower.json'
    end

    def versions
      vers = ['node --version']
      vers += ['npm --version'] if npm?
      vers += ['bower --version'] if bower?
      vers += ['grunt --version'] if grunt?
      vers
    end

    def exist?(file)
      File.exist?(File.join(application.path, file))
    end

  end
end
