require "http/client"

module Launch::Serverless
  class Server
    getter runtime : Launch::Serverless::Runtime::Base
    getter request_handler : Launch::Serverless::HTTPRequest::Base.class
    getter response_handler : Launch::Serverless::HTTPResponse::Base.class

    def self.instance
      @@instance ||= new
    end

    def self.start
      instance.run
    end

    def initialize
      spawn name: "server" do
        Launch::Server.start
      end

      case Launch.settings.serverless_provider
      when :lambda
        @runtime = Lambda::Runtime.new
        @request_handler = Launch::Serverless::Lambda::HTTPRequest
        @response_handler = Launch::Serverless::Lambda::HTTPResponse
      when nil
        raise "Serverless Enabled But No Provider"
      else
        raise "Invalid Serverless Provider"
      end
    end

    def run
      runtime.register_handler("httpevent") do |input|
        req = request_handler.new(input)
        Log.info { "REQUEST: #{req.inspect}" }

        url = "#{Launch.settings.host}:#{Launch.settings.port}#{req.resource}"
        Log.info { url }
        response =
          HTTP::Client.get(
            url,
            headers: req.headers,
            body: req.body
          )

        JSON.parse(
          response_handler.new(
            status_code: response.status_code,
            headers: response.headers,
            body: response.body
          ).to_json
        )
      end

      runtime.run
    end
  end
end
