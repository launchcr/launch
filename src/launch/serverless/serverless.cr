require "http/client"

module Launch
  class Serverless
    getter runtime : Launch::Serverless::RuntimeInterface

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
      when nil
        raise "Serverless Enabled But No Provider"
      else
        raise "Invalid Serverless Provider"
      end
    end

    def run
      runtime.register_handler("httpevent") do |input|
        req = Lambda::Builder::HTTPRequest.new(input)
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
          Lambda::Builder::HTTPResponse.new(
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
