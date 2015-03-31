require 'builder/component/version'

class Builder
  class Component
    def initialize(component:, versions:)
      self.component = component
      self.versions = Version.versions(component: component, versions: versions)
    end

    def build
      versions.map(&:build)
    end

    protected

    attr_accessor :component, :versions

  end
end
