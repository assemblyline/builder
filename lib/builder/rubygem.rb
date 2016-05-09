require "builder/ruby"

class Builder
  class Rubygem < Ruby
    private

    def dockerfile_template
      File.expand_path("../rubygem/Dockerfile.erb", __FILE__)
    end
  end
end
