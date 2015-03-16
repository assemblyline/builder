require 'toml'

module Assemblyfile
  def self.load(dir)
    TOML.load_file(File.join(dir, 'Assemblyfile'))['application'].map { |app| Application.new(app, dir) }
  end

  class Application
    def initialize(data, dir)
      self.name = data['name']
      self.path = File.expand_path(File.join(dir, data['path']))
      self.builder = load_builder(data['build'])
    end

    attr_reader :builder, :path, :name

    def build
      builder.build
    end

    def push
      builder.push
    end
    
    protected

    attr_writer :builder, :path, :name

    private

    def load_builder(build)
      name = build['builder']
      require "builder/#{name.downcase}"
      Module.const_get("Builder::#{name}").new(application: self, build: build)
    end
  end
end
