class DockerURI
  def initialize(uri_string)
    @string = uri_string
  end

  def image
    path.last
  end

  def tag
    parts[1] || "latest"
  end

  def repo
    case path.size
    when 2
      path[0]
    when 3
      path[1]
    end
  end

  def registry
    return unless path.size == 3
    path[0]
  end

  private

  def path
    parts.first.split("/")
  end

  def parts
    @string.split(":")
  end
end
