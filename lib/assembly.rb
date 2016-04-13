require "docker"
require "json"
require "colorize"
require "builder"
require "log"
require "github_status"

class Assembly
  attr_reader :builder, :path, :name, :repo

  def build
    GithubStatus.start_build(sha: sha)
    self.images = [builder.build]
    GithubStatus.tests_complete(sha: sha)
    Log.out.puts "sucessfully assembled #{full_tag}".bold.green
  rescue => e
    GithubStatus.error(sha: sha)
    raise e
  end

  def push
    if @local_repo
      Log.err.puts "no repo specified in config only building project localy"
    else
      GithubStatus.pushing_image(sha: sha)
      push_image
    end
    GithubStatus.image_pushed(sha: sha, image_url: "https://#{full_tag}")
  rescue => e
    GithubStatus.push_error(sha: sha)
    raise e
  end

  def full_tag
    "#{repo}:#{tag}"
  end

  def tag
    @_tag ||= "#{sha}_#{timestamp}"
  end


  protected

  attr_writer :builder, :path, :name, :repo
  attr_accessor :sha, :images

  private

  def push_image
    auth_docker
    images.each do |image|
      Log.out.puts "pushing #{image.info["RepoTags"].first} =>".bold.green
      image.push { |chunk| format_push_status(chunk) }
    end
  end

  def auth_docker
    dockercfg.each do |index, config|
      Docker.authenticate!(
        "email" => config["email"],
        "username" => username(config["auth"]),
        "password" => password(config["auth"]),
        "serveraddress" => index,
      )
    end
  end

  def format_push_status(chunk)
    json = JSON.parse(chunk)
    output_error(json["error"])
    output_status(json["status"])
  end

  def output_status(status)
    case status
    when "Pushing", "Buffering to disk"
      Log.out.print "."
    when "Image successfully pushed"
      Log.out.puts "\n" + status
    else
      Log.out.puts status
    end
  end

  def output_error(error)
    return unless error
    Log.err.puts error
    exit 1
  end

  def username(auth)
    decode(auth).first
  end

  def password(auth)
    decode(auth).last
  end

  def decode(auth)
    Base64.decode64(auth).split(":")
  end

  def dockercfg
    cfg = JSON.parse(ENV["DOCKERCFG"])
    # in docker 1.7 ~/.dockercfg was replaced
    # with ~/.docker/config.json, the format is *almost* identical
    cfg["auths"] || cfg
  end

  def timestamp
    Time.now.strftime("%Y%m%d%H%M%S")
  end

  def local_repo
    @local_repo ||= name.downcase.gsub(/[^a-z0-9\-_.]/, "_")
  end
end
