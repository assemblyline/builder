require 'rspec/core'
require 'specinfra/core'

class Builder
  class Component
    class SpecRunner
      def initialize(version:, version_tags:, path:)
        self.version = version
        self.versions = version_tags
        self.path = path
      end

      def run
        reset_rspec!(version.image)
        exit_code = RSpec::Core::Runner.run(spec_command, Log.err, Log.out)
        exit exit_code unless exit_code == 0
      end

      protected

      attr_accessor :version, :versions, :path

      def reset_rspec!(image)
        Specinfra::Backend::Docker.instance_variable_set(:@instance, nil)
        RSpec.reset
        RSpec.configuration.before(:all) do
          set :backend, :docker
          set :docker_image, image.id
        end
      end

      def spec_command
        [File.join(path, 'spec')] + (versions - [version.tag]).map { |v| ['-t', "~#{v}"] }.flatten
      end
    end
  end
end
