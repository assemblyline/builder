require 'assembly'
require 'builder'

class Application < Assembly
  def initialize(data, dir, sha)
    self.sha = sha
    self.name = data['application']['name']
    self.path = dir
    self.builder = Builder.load_builder(application: self, build: data['build'])
    self.repo = data['application']['repo'] || local_repo
  end
end
