require 'services/service'
require 'colorize'
require 'log'

module Services
  class RabbitMQ < Service
    def env
      { 'AMQP_URI' => amqp_uri }
    end

    private

    def amqp_uri
      "amqp://guest:guest@#{ip}:5672"
    end
  end
end
