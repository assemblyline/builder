require 'minigit'
require 'securerandom'
require 'log'

class GitRepo

  def self.clone(*args)
    MiniGit::Capturing.git :clone, *args
  end

  def initialize(path)
    @git = MiniGit::Capturing.new(path)
  end

  def sha
    git.rev_parse({ short: true }, :HEAD).chomp
  end

  def fetch
    git.fetch
  end

  def merge(ref)
    git.checkout({ b: working_branch }, ref)
    git.checkout :master
    git.merge(working_branch, 'no-ff' => true, m: 'merge branch working copy')
    git.branch(d: working_branch)
  end

  private

  def working_branch
    @_working_branch ||= "assemblyline-#{SecureRandom.urlsafe_base64}"
  end

  attr_reader :git
end
