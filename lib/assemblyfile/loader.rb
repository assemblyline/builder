require 'toml'
require 'application'

module Assemblyfile
  def self.load(dir)
    TOML.load_file(File.join(dir, 'Assemblyfile'))['application'].map { |app| Application.new(app, dir) }
  end

end
