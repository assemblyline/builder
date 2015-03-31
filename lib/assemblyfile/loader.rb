require 'toml'

module Assemblyfile
  extend self

  def load(dir, sha)
    app_dirs(dir).map do |app_dir|
      to_assembly(app_dir, sha)
    end
  end

  private

  def to_assembly(dir, sha)
    data = get_data(dir)
    if data['application']
      require 'application'
      Application.new(data, dir, sha)
    elsif data['component']
      require 'component'
      Component.new(data, dir, sha)
    end
  end

  def get_data(dir)
    TOML.load_file(File.join(dir, 'Assemblyfile'))
  end

  def app_dirs(dir)
    Dir[dir + '/**/Assemblyfile'].sort.map { |file| File.dirname(file) }
  end
end
