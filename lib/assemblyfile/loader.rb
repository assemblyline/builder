require 'toml'

module Assemblyfile
  extend self

  def load(dir, sha)
    assemblyfiles(dir).map do |assemblyfile, app_dir|
      to_assembly(assemblyfile, app_dir, sha)
    end
  end

  private

  def to_assembly(assemblyfile, dir, sha)
    data = get_data(assemblyfile)
    if data['application']
      require 'application'
      Application.new(data, dir, sha)
    elsif data['component']
      require 'component'
      Component.new(data, dir, sha)
    end
  end

  def get_data(path)
    TOML.load_file(path)
  end

  def assemblyfiles(dir)
    Dir[dir + '/**/Assemblyfile*'].sort.map { |file| [file, File.dirname(file)] }
  end
end
