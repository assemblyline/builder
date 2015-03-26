require 'docker'
require 'erb'
require 'builder/dockerfile'
require 'container_runner'
require 'services'

class Builder
  class Ruby
    def initialize(application:, build:)
      self.application = application
      self.ruby_version = build['version'] || detect_ruby_version
      self.ignore = build['ignore'] || []
      self.script = build['script']
      self.services = Services.build(application, build['service'])
      self.env = build.fetch('env', {})
    end

    def build
      dockerfile_build
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
    end

    def exit_if_failed
      return if exit_code == 0
      exit exit_code
    end

    def exit_code
      test_container.json['State']['ExitCode']
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
      @script || ['bundle exec rake']
    end

    def dockerfile_build
      write_config
      self.image = Dockerfile.new(application: application).build
    end

    def write_config
      File.write(path('Dockerfile'), ERB.new(File.read(dockerfile_template)).result(binding))
      File.write(path('.dockerignore'), ignore.join("\n"))
    end

    def dockerfile_template
      File.expand_path('../ruby/Dockerfile.erb', __FILE__)
    end

    def path(file)
      File.join(application.path, file)
    end

    def ignore
      @ignore + ['.git']
    end

    def detect_ruby_version
      config_path = File.join(application.path, '.ruby-version')
      return 'latest' unless File.exist? config_path
      File.read(config_path).chomp
    end
  end
end
