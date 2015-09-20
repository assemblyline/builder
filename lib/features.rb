module Features
  extend self

  # For now killing containers does not work on travis ci
  # It is not really an issue as they can do as they wish to
  # clean up after us
  def kill?
    !ENV['TRAVIS']
  end
end
