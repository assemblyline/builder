require "octokit"
require "git_url"

module GithubStatus
  extend self

  def git_url
    GitUrl.new(ENV["GIT_URL"]) if ENV["GIT_URL"]
  end

  def access_token
    ENV["GITHUB_ACCESS_TOKEN"]
  end

  def build_url
    ENV["BUILD_URL"]
  end

  def client
    @_client ||= Octokit::Client.new(access_token: access_token)
  end

  def start_build(sha:)
    status(status: "pending", sha: sha, context: "build", description: "Container build in progress")
    status(status: "pending", sha: sha, context: "test",  description: "Tests in progress")
  end

  def tests_complete(sha:)
    status(status: "pending", sha: sha, context: "test",  description: "Tests passed")
  end

  def pushing_image(sha:)
    status(status: "pending", sha: sha, context: "build", description: "Pushing to container repository")
  end

  def image_pushed(sha:, image_url:)
    status(status: "success", url: image_url, sha: sha, context: "build", description: "Container build complete")
  end

  def error(sha:)
    status(status: "failure", sha: sha, context: "test",   description: "Tests did not pass")
    status(status: "failure", sha: sha, context: "build",  description: "Container build error")
  end

  def push_error(sha:)
    status(status: "failure", sha: sha, context: "build",  description: "Container push error")
  end

  private

  def status(status:, context:, url: nil, description:, sha:)
    return unless access_token && git_url && git_url.github?
    client.create_status(
      git_url.repo,
      sha,
      status,
      context: "assemblyline/#{context}",
      target_url: url || build_url,
      description: description,
    )
  end
end
