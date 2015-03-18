class Application
  def initialize(data, dir)
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

  private

  def auth_docker
    Docker.authenticate!(
      'username' => ENV['DOCKER_USERNAME'],
      'password' => ENV['DOCKER_PASSWORD'],
      'serveraddress' => ENV['DOCKER_REPO_ADDR']
    )
  end

  def timestamp
    Time.now.strftime('%Y%m%d%H%M%S')
  end

  def sha
    GitRepo.new(path).sha
  end

  def load_builder(build)
    name = build['builder']
    require "builder/#{name.downcase}"
    Module.const_get("Builder::#{name}").new(application: self, build: build)
  end
end
