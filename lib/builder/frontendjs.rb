require "colorize"
require "docker"
require "builder/dockerfile"
require "builder/frontendjs/install"
require "container_runner"

class Builder
  class FrontendJS
    def initialize(application:, build:)
      self.application = application
      self.script = build["script"]
      self.install = build["install"]
      self.node_version = build["version"] || "0.12.0"
      self.target = File.join(application.path, build["target"] || "dist")
    end

    def build
      setup_build
      run_build
      package_target
    end

    protected

    attr_accessor :application, :target, :container, :install, :node_version
    attr_writer :script

    private

    def setup_build
      prepare_install
      self.container = ContainerRunner.new(
        image: "quay.io/assemblyline/builder-frontendjs:#{node_version}",
        script: script,
        env: { "SSH_KEY" => ENV["SSH_KEY"] },
      )
    end

    def prepare_install
      self.install = Install.new(script: install, path: application.path)
    end

    def run_build
      container.run
      install.save_caches
    end

    def package_target
      generate_dockerfile
      Dockerfile.new(application: application, path: target).build
    end

    def generate_dockerfile
      write ".dockerignore", "Dockerfile\n.dockerignore"
      write "Dockerfile", "FROM nginx\nCOPY . /usr/share/nginx/html"
    end

    def write(name, content)
      file = File.new(File.join(target, name), "w")
      file.write content
      file.close
    end

    def script
      ["cd #{application.path}"] + (install.script + (@script || grunt))
    end

    def grunt
      return [] unless grunt?
      ["grunt"]
    end

    def grunt?
      exist? "Gruntfile.js"
    end

    def exist?(file)
      File.exist?(File.join(application.path, file))
    end
  end
end
