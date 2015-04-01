require 'erb'
require 'builder/dockerfile'
require 'rspec/core'
require 'specinfra/core'

class Builder
  class Component
    class Version
      def self.versions(component:, versions:)
        versions.map { |data| new(data: data, component: component, versions: versions) }
      end

      def initialize(component:, data:, versions:)
        self.component = component
        self.data = data
        self.versions = versions.map { |version| version['version'] }
      end

      def build
        write_config
        dockerfile_build
        spec
        image
      end

      def template_paths
        grouped_templates.map do |base_file, candidates|
          candidates.detect { |t| t.include?(data['version']) } || base_file
        end
      end

      def tag
        data['version']
      end

      def repo
        component.repo
      end

      protected

      attr_accessor :data, :component, :versions, :image

      private

      def dockerfile_build
        self.image = Dockerfile.new(application: self, path: component.path).build
      end

      def spec
        reset_rspec!(image)
        exit_code = RSpec::Core::Runner.run(spec_command, Log.err, Log.out)
        exit exit_code unless exit_code == 0
        Log.out.puts "sucessfully assembled #{repo}:#{tag}".bold.green
      end

      def reset_rspec!(image)
        Specinfra::Backend::Docker.instance_variable_set(:@instance, nil)
        RSpec.reset
        RSpec.configuration.before(:all) do
          set :backend, :docker
          set :docker_image, image.id
        end
      end

      def spec_command
        [File.join(component.path, 'spec')] + (versions - [tag]).map { |v| ['-t', "~#{v}"] }.flatten
      end

      def write_config
        Log.out.puts "assembling #{component.name} version:#{tag}".bold.green
        templates.each do |template, path|
          File.write(path, template.result(binding))
        end
      end

      def templates
        template_paths.map { |t| [ERB.new(File.read(t)), path(t)] }
      end

      def path(template_path)
        tp = template_path.dup
        tp.slice!('/templates')
        strip_version(tp.split('.erb').first)
      end

      def grouped_templates
        Dir[component.path + '/templates/**/**.erb'].group_by do |template|
          strip_version(template)
        end
      end

      def strip_version(template)
        t = template.dup
        versions.each { |v| t.slice!('/' + v) }
        t
      end
    end
  end
end
