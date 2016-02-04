require "builder/component/version"
require "builder/component/templates"

class Builder
  class Component
    def initialize(component:, versions:)
      self.versions = Version.versions(component: component, versions: versions)
      self.templates = Templates.new(path: component.path, versions: self.versions)
    end

    def build
      versions.map(&:build)
    end

    attr_reader :templates

    protected

    attr_accessor :versions
    attr_writer :templates

  end
end
