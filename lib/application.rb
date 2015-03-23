require 'docker'
require 'json'
require 'colorize'
require 'builder'

class Application
  def initialize(data, dir, sha)
    self.sha = sha
    self.name = data['application']['name']
    self.path = dir
    self.builder = Builder.load_builder(application: self, build: data['build'])
    self.repo = data['application']['repo']
  end

  attr_reader :builder, :path, :name, :repo

  def build
    builder.build
  end

  def push
    auth_docker
    printf "pushing #{full_tag} =>".bold.green
    image = Docker::Image.get(full_tag)
    image.tag('repo' => repo, 'tag' => tag, 'force' => true)
    image.push('tag' => 'foofoo') { |chunk| format_push_status(chunk) }
  end

  def full_tag
    "#{repo}:#{tag}"
  end

  def tag
    @_tag ||= "#{sha}_#{timestamp}"
  end

  protected

  attr_writer :builder, :path, :name, :repo
  attr_accessor :sha

  private

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
    require 'pry'
    binding.pry
    print json['status']
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
end
