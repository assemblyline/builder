require 'assembly'
require 'builder/component'

class Component < Assembly
  def initialize(data, dir, sha)
    self.sha = sha
    self.name = data['component']['name']
    self.path = dir
    self.builder = Builder::Component.new(component: self, versions: data['version'])
    self.repo = data['component'].fetch('repo')
  end

  def build
    self.images = builder.build
  end

end
