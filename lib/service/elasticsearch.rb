require 'docker'
require 'net/http'

module Service
  class Elasticsearch
    def initialize(application:, data:)
      self.application = application
      self.data = data
    end

    def start
      self.container ||= Docker::Container.create('Image' => 'elasticsearch')
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
