require "builder/dockerfile"
require "builder/component/spec_runner"
require "colorize"

class Builder
  class Component
    class Version
      def self.versions(component:, versions:)
        versions.map { |data| new(data: data, component: component, versions: versions) }
      end

      def initialize(component:, data:, versions:)
        self.component = component
        self.data = data
        self.spec_runner = SpecRunner.new(
          path: component.path,
          version: self,
          version_tags: versions.map { |version| version["version"] },
        )
      end

      attr_reader :image

      def build
        write_config
        dockerfile_build
        spec_runner.run
        Log.out.puts "sucessfully assembled #{repo}:#{tag}".bold.green
        image
      end

      def tag
        data["version"]
      end

      def repo
        component.repo
      end

      def template
        data["template"]
      end

      protected

      attr_accessor :data, :component, :versions, :spec_runner
      attr_writer :image

      private

      def dockerfile_build
        self.image = Dockerfile.new(application: self, path: component.path).build
      end

      def write_config
        Log.out.puts "assembling #{component.name} version:#{tag}".bold.green
        templates.each { |t| t.write_config(binding) }
      end

      def templates
        component.builder.templates.for(self)
      end

    end
  end
end
