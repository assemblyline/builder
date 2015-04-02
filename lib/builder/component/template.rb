require 'erb'

class Builder
  class Component
    class Template
      def initialize(path:, output:)
        self.path = path
        self.output = output
      end

      attr_reader :path, :output

      def ==(other)
        other.path == path && other.output == output
      end

      def write_config(context)
        File.write(output, ERB.new(File.read(path)).result(context))
      end

      protected

      attr_writer :path, :output
    end
  end
end
