module Log
  extend self

  def out
    STDOUT
  end

  def err
    STDERR
  end
end
