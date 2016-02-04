require "net/http"
require "services/service"

module Services
  class Riak < Service

    def start
      super
      wait
      create_bucket_types
    end

    def env
      { "RIAK_NODES" => "#{ip}:8087" }
    end

    private

    def wait
      sleep(0.1) until ping == "200"
    rescue Errno::ECONNREFUSED
      sleep 0.1
      retry
    end

    def ping
      uri = URI("https://riakuser:sekret@#{ip}:8098/buckets?buckets=true")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.code
    end

    def create_bucket_types
      return unless data["bucket_types"]
      data["bucket_types"].each do |bucket_type|
        Log.out.puts "creating riak bucket type: #{bucket_type}"
        %w(create activate).each do |action|
          _out, _err, status = container.exec(["riak-admin", "bucket-type", action, bucket_type])
          fail unless status == 0
        end
      end
    end

    def image
      "tutum/#{super}"
    end
  end
end
