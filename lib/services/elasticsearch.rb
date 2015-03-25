require 'docker'
require 'net/http'

module Services
  class Elasticsearch
    def initialize(application:, data:)
      self.application = application
      self.data = data
    end

    def start
      pull_image_if_required
      self.container ||= Docker::Container.create('Image' => image)
      container.start
      wait
    end

    def env
      { "ES_URL" => es_url }
    end

    def stop
      container.delete(force: true)
    end

    protected

    attr_accessor :application, :data, :container

    private

    def es_url
      "#{ip}:9200"
    end

    def pull_image_if_required
      Docker::Image.get(image)
    rescue Docker::Error::NotFoundError
      Docker::Image.create('fromImage' => image) { |c| print c }
    end

    def image
      "elasticsearch:#{version}"
    end

    def version
      data['version'] || 'latest'
    end

    def wait
      uri = URI("http://#{es_url}")
      until Net::HTTP.get_response(uri).code == '200'
        sleep 0.1
      end
    rescue Errno::ECONNREFUSED
      sleep 0.1
      retry
    end

    def ip
      container.json["NetworkSettings"]["IPAddress"]
    end
  end
end
