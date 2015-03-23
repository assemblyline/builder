require 'toml'
require 'application'

module Assemblyfile
  extend self

  def load(dir, sha)
    app_dirs(dir).map { |app_dir| Application.new(TOML.load_file(File.join(app_dir, 'Assemblyfile')), app_dir, sha) }
  end

  private

  def app_dirs(dir)
    Dir[dir + '/**/Assemblyfile'].sort.map { |file| File.dirname(file) }
  end
end
