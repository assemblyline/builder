require 'addressable/template'

class GitUrl
  def initialize(url)
    @url = url
    validate!
  end

  def cache_path
    "/etc/assemblyline/git_cache/#{host}/#{org}/#{repo}"
  end

  attr_reader :url

  def repo
    parts['repo']
  end

  private

  def validate!
    fail ArgumentError, 'repo url must be valid' unless parts
  end

  def uri
    Addressable::URI.parse(url)
  end

  def host
    parts['host']
  end

  def org
    parts['org']
  end


  def parts
    temp = nil
    templates.detect { |t| temp = t.extract(uri) }
    temp
  end

  def templates
    %w(
      {user}@{host}:{org}/{repo}.git
      {protocol}://{host}/{org}/{repo}.git
    ).map { |t| Addressable::Template.new t }
  end
end
