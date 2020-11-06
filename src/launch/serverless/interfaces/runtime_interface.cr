module Launch::Serverless
  module RuntimeInterface
    # The host for the provider.
    abstract def host : String

    # The port for the provider.
    abstract def port : Int16

    # List of function handlers.
    abstract def handlers : Hash(String, (JSON::Any -> JSON::Any))

    # Custom logger for streaming logs.
    abstract def logger : Logger

    # Set the function handlers.
    abstract def register_handler(name : String, &handler : JSON::Any -> JSON::Any)

    # Begin processing a request
    abstract def run

    # Processes a request if the handler exists otherwise logs errors
    abstract def process_handler

    # Processes a single request.
    # Should fetch a request from the provider and return it when
    # the request is finished.
    private abstract def process_request(proc : Proc(JSON::Any, JSON::Any))
  end
end
