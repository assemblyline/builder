require 'builder'
require 'thor'

class CLI < Thor
  desc 'build GIT_URL', 'build from a git url optionaly merge reg with master'
  option :push, type: :boolean, default: false
  def build(url, ref=nil)
    Builder.new(url: url, branch: ref, push: options[:push]).build
  end

  desc 'local_build SHA', 'build from source mounted at /usr/assemblyline/local'
  option :push, type: :boolean, default: false
  def local_build(sha)
    Builder.local_build(sha: sha, push: options[:push])
  end
end
