require "docker"
require "log"
require "docker_uri"

class ContainerRunner
  def initialize(image:, script:, env: {})
    self.image = image
    self.script = script
    self.env = env
  end

  def run
    set_read_timeout
    container.start("Binds" => ["/tmp:/tmp:rw"])
    attach
    container.delete
    exit_if_failed
  end

  protected

  attr_accessor :image, :script, :code
  attr_writer :env

  private

  def command
    ["bash", "-xce", script.map { |c| c + " ;" }.join]
  end

  def env
    @env.merge("PS4" => "$ ").map { |var, val| "#{var}=#{val}" }
  end

  def container
    @_container ||= Docker::Container.create(
      "Cmd" => command,
      "Image" => image,
      "Volumes" => { "/tmp" => {} },
      "Env" => env,
    )
  rescue Docker::Error::NotFoundError => e
    raise e if @pulled
    pull_image
    @pulled = true
    retry
  end

  def pull_image
    uri = DockerURI.new(image)
    Docker::Image.create(
      "fromImage" => image
    ) do |*args|
      puts args.inspect
    end
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
    self.code = exit_code
  end

  def exit_if_failed
    return if code == 0
    exit code
  end

  def exit_code
    container.json["State"]["ExitCode"]
  end

  def set_read_timeout
    Excon.defaults[:read_timeout] = 1000
    Docker.options = { chunk_size: 32 }
  end
end
