require "http"
require "logger"

module Launch::Serverless::Lambda
  class Runtime
    include Launch::Serverless::RuntimeInterface

    AWS_LAMBDA_RUNTIME_API = "/2018-06-01/runtime/invocation/next"

    getter host : String
    getter port : Int16
    getter handlers : Hash(String, (JSON::Any -> JSON::Any)) = Hash(String, (JSON::Any -> JSON::Any)).new
    getter logger : Logger

    def initialize(@logger : Logger = Logger.new(STDOUT, level: Logger::DEBUG))
      api = ENV["AWS_LAMBDA_RUNTIME_API"].split(":", 2)

      @host = api[0]
      @port = api[1].to_i16

      # easier to read logging within the lambda, includes the handler name
      @logger.formatter = Logger::Formatter.new do |severity, datetime, _progname, message, io|
        label = severity.unknown? ? "ANY" : severity.to_s
        io << "[" << datetime.to_rfc3339 << "] ["
        io << label.rjust(5) << "] [" << ENV["_HANDLER"] << "] [" << message << "]"
      end
    end

    # Associate the block/proc to the function name
    def register_handler(name : String, &handler : JSON::Any -> JSON::Any)
      self.handlers[name] = handler
    end

    def run
      loop do
        process_handler
      end
    end

    def process_handler
      handler_name = ENV["_HANDLER"]

      if handlers.has_key?(handler_name)
        process_request handlers[handler_name]
      else
        logger.error("unknown handler: #{handler_name}, available handlers: #{handlers.keys.join(", ")}")
      end
    end

    private def process_request(proc : Proc(JSON::Any, JSON::Any))
      client = HTTP::Client.new(host: @host, port: @port)

      begin
        response = client.get
        ENV["_X_AMZN_TRACE_ID"] = response.headers["Lambda-Runtime-Trace-Id"] || ""

        aws_request_id = response.headers["Lambda-Runtime-Aws-Request-Id"]
        base_url = "/2018-06-01/runtime/invocation/#{aws_request_id}"

        input = JSON.parse response.body
        body = proc.call input

        logger.info("preparing body #{body}")
        response = client.post("#{base_url}/response", body: body.to_json)
        logger.debug("response invocation response #{response.status_code} #{response.body}")
      rescue ex
        body = %Q({ "statusCode": 500, "body" : "#{ex.message}" })
        response = client.post("#{base_url}/error", body: body)
        logger.error("response error invocation response from exception " \
                     "#{ex.message} #{response.status_code} #{response.body}")
      ensure
        client.close
      end
    end
  end
end
