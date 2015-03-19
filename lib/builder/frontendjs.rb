require 'colorize'
require 'docker'
require 'mtime'

class Builder
  class FrontendJS
    def initialize(application:, build:)
      self.application = application
      self.script = build['script']
      self.target = File.join(application.path, build['target'] || 'dist')
      self.container = create_container
      set_read_timeout
    end

    def build
      run_build
      package_target
    end

    protected

    attr_accessor :application, :target, :container
    attr_writer :script

    private

    def set_read_timeout
      Excon.defaults[:read_timeout] = 1000
    end

    def run_build
      container.start('Binds' => ['/tmp:/tmp:rw'])
      attach
      exit_if_failed
      container.delete
    end

    def package_target
      generate_dockerfile
      Mtime.clobber(target)
      image = Docker::Image.build_from_dir(target) { |chunk| puts JSON.parse(chunk)['stream'] }
      image.tag('repo' => application.repo, 'tag' => application.tag)
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

    def exit_if_failed
      return if exit_code == 0
      exit exit_code
    end

    def exit_code
      container.json['State']['ExitCode']
    end

    def create_container
      Docker::Image.create('fromImage' => 'quay.io/assemblyline/builder-frontendjs')
      Docker::Container.create(
        'Cmd' => command,
        'Image' => 'quay.io/assemblyline/builder-frontendjs',
        'Volumes' => { '/tmp' => {} },
        'Env' => ["SSH_KEY=#{ENV['SSH_KEY']}"],
      )
    end

    def command
      ['bash', '-c', script.join(' && ')]
    end

    def script
      ["cd #{application.path}"] + (@script || npm + bower + grunt)
    end

    def grunt
      return [] unless File.exist?(File.join(application.path, 'Gruntfile.js'))
      ['grunt']
    end

    def npm
      return [] unless File.exist?(File.join(application.path, 'package.json'))
      ['npm install']
    end

    def bower
      return [] unless File.exist?(File.join(application.path, 'bower.json'))
      ['bower install --allow-root']
    end

    def attach
      container.attach(logs: true) do |stream, chunk|
        printf "#{stream}: ".red if stream != :stdout
        puts chunk
      end
    end
  end
end
