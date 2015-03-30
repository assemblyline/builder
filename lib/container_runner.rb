require 'docker'
require 'log'

class ContainerRunner
  def initialize(image:, script:, env: {})
    self.image = image
    self.script = script
    self.env = env
  end

  def run
    set_read_timeout
    container.start('Binds' => ['/tmp:/tmp:rw'])
    attach
    exit_if_failed
    container.delete
  end

  protected

  attr_accessor :image, :script
  attr_writer :env

  private

  def command
    ['bash', '-xce', script.map { |c| c + ' ;' }.join]
  end

  def env
    @env.merge('PS4' => '$ ').map { |var, val| "#{var}=#{val}" }
  end

  def container
    @_container ||= Docker::Container.create(
      'Cmd' => command,
      'Image' => image,
      'Volumes' => { '/tmp' => {} },
      'Env' => env,
    )
  end

  def attach
    container.attach(logs: true) do |stream, chunk|
      case stream
      when :stdout
        Log.out.print chunk
      when :stderr
        Log.err.print chunk
      else
        Log.err.print "#{stream}: #{chunk}"
      end
    end
  end

  def exit_if_failed
    return if exit_code == 0
    exit exit_code
  end

  def exit_code
    container.json['State']['ExitCode']
  end

  def set_read_timeout
    Excon.defaults[:read_timeout] = 1000
    Docker.options = { chunk_size: 32 }
  end
end
