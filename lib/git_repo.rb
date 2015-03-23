require 'minigit'
require 'securerandom'

class GitRepo

  def self.clone(*args)
    MiniGit.git :clone, *args
  end

  def initialize(path)
    @git = MiniGit.new(path)
  end

  def sha
    cgit.rev_parse({ short: true }, :HEAD).chomp
  end

  def fetch
    git.fetch
  end

  def merge(ref)
    cgit.checkout({ b: working_branch }, ref)
    cgit.checkout :master
    cgit.merge(working_branch, 'no-ff' => true, m: 'merge branch working copy')
    cgit.branch(d: working_branch)
  end

  private

  def working_branch
    @_working_branch ||= "assemblyline-#{SecureRandom.urlsafe_base64}"
  end

  def cgit
    git.capturing
  end

  attr_reader :git
end
