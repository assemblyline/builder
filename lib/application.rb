require 'json'

class Application
  def initialize(data, dir, sha)
    self.sha = sha
    self.name = data['name']
    self.path = File.expand_path(File.join(dir, data['path']))
    self.builder = load_builder(data['build'])
    self.repo = data['repo']
  end

  attr_reader :builder, :path, :name, :repo

  def build
    builder.build
  end

  def push
    auth_docker
    Docker::Image.get(full_tag).push { |s| puts JSON.parse(s)['status'] }
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

  def load_builder(build)
    name = build['builder']
    require "builder/#{name.downcase}"
    Module.const_get("Builder::#{name}").new(application: self, build: build)
  end
end
