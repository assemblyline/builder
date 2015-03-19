require 'minigit'

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

  def pull
    git.pull
  end

  private

  def cgit
    git.capturing
  end

  attr_reader :git
end
