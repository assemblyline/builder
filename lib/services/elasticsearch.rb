require 'net/http'
require 'services/service'

module Services
  class Elasticsearch < Service
    def start
      super
      wait
    end

    def env
      { 'ES_URL' => es_url }
    end

    protected

    attr_accessor :application, :data, :container

    private

    def es_url
      "#{ip}:9200"
    end

    def wait
      uri = URI("http://#{es_url}")
      sleep(0.1) until Net::HTTP.get_response(uri).code == '200'
    rescue Errno::ECONNREFUSED
      sleep 0.1
      retry
    end
  end
end
