require 'docker'
require 'json'
require 'colorize'
require 'builder'
require 'service'

class Application
  def initialize(data, dir, sha)
    self.sha = sha
    self.name = data['application']['name']
    self.path = dir
    self.builder = Builder.load_builder(application: self, build: data['build'])
    self.services = Service.build(self, data['test'])
    self.repo = data['application']['repo'] || local_repo
    self.env = data.fetch('test', {}).fetch('env', {})
  end

  attr_reader :builder, :path, :name, :repo, :services

  def build
    self.image = builder.build
    puts "sucessfully assembled #{full_tag}".bold.green
  end

  def push
    if @local_repo
      $stderr.puts 'no repo specified in config only building project localy'
    else
      push_image
    end
  end

  def full_tag
    "#{repo}:#{tag}"
  end

  def tag
    @_tag ||= "#{sha}_#{timestamp}"
  end

  def start_services
    services.each(&:start)
  end

  def stop_services
    services.each(&:stop)
  end

  def env
    @env.merge(services.map(&:env).reduce({}, :merge))
  end

  protected

  attr_writer :builder, :path, :name, :repo, :services, :env
  attr_accessor :sha, :image

  private

  def push_image
    auth_docker
    puts "pushing #{full_tag} =>".bold.green
    image.push { |chunk| format_push_status(chunk) }
  end

  def auth_docker
    dockercfg.each do |index, config|
      Docker.authenticate!(
        'email' => config['email'],
        'username' => username(config['auth']),
        'password' => password(config['auth']),
        'serveraddress' => index,
      )
    end
  end

  def format_push_status(chunk)
    json = JSON.parse(chunk)
    output_error(json['error'])
    output_status(json['status'])
  end

  def output_status(status)
    case status
    when 'Pushing', 'Buffering to disk'
      print '.'
    when 'Image successfully pushed'
      puts "\n" + status
    else
      puts status
    end
  end

  def output_error(error)
    return unless error
    $stderr.puts error
    exit 1
  end

  def username(auth)
    decode(auth).first
  end

  def password(auth)
    decode(auth).last
  end

  def decode(auth)
    Base64.decode64(auth).split(':')
  end

  def dockercfg
    JSON.parse(ENV['DOCKERCFG'])
  end

  def timestamp
    Time.now.strftime('%Y%m%d%H%M%S')
  end

  def local_repo
    @local_repo ||= name.downcase.gsub(/[^a-z0-9\-_.]/, '')
  end
end
