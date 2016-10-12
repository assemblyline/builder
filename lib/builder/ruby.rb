require "docker"
require "erb"
require "builder/dockerfile"
require "container_runner"
require "services"

class Builder
  class Ruby
    def initialize(application:, build:)
      self.application = application
      self.ruby_version = build["version"] || detect_ruby_version
      self.ignore = build["ignore"] || []
      self.script = build["script"]
      self.services = Services.build(application, build["service"])
      self.env = build.fetch("env", {})
    end

    def build(pushable)
      dockerfile_build(pushable)
      run_script
      image
    end

    protected

    attr_accessor :application, :ruby_version, :image, :services
    attr_writer :ignore, :script, :env

    private

    def start_services
      services.each(&:start)
    end

    def stop_services
      services.each(&:stop)
    end

    def env
      @env.merge(services.map(&:env).reduce({}, :merge))
        .merge(ci_env)
    end

    def ci_env
      { "CI" => ENV["CI"], "CI_MASTER" => ENV["CI_MASTER"] }.reject { |_, v| v.nil? }
    end

    def exit_if_failed
      return if exit_code == 0
      exit exit_code
    end

    def exit_code
      test_container.json["State"]["ExitCode"]
    end

    def run_script
      start_services
      ContainerRunner.new(
        image: application.full_tag,
        script: script,
        env: env,
      ).run
    ensure
      stop_services
    end

    def script
      @script || ["bundle exec rake"]
    end

    def dockerfile_build(pushable)
      write_config
      self.image = Dockerfile.new(application: application).build(pushable)
    end

    def write_config
      write("Dockerfile", ERB.new(File.read(dockerfile_template)).result(binding))
      write(".dockerignore", ignore.join("\n"))
    end

    def write(filename, content)
      File.write(path(filename), content) unless File.exist? path(filename)
    end

    def dockerfile_template
      File.expand_path("../ruby/Dockerfile.erb", __FILE__)
    end

    def path(file)
      File.join(application.path, file)
    end

    def ignore
      @ignore + [".git", "Assemblyfile"]
    end

    def detect_ruby_version
      return "latest" unless File.exist? path(".ruby-version")
      File.read(path(".ruby-version")).chomp
    end
  end
end
