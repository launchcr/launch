require "./cluster"
require "./ssl"

module Launch
  class Server
    include Launch::DSL::Server
    alias WebSocketAdapter = WebSockets::Adapters::RedisAdapter.class | WebSockets::Adapters::MemoryAdapter.class
    property pubsub_adapter : WebSocketAdapter = WebSockets::Adapters::MemoryAdapter
    getter handler = Pipe::Pipeline.new
    getter router = Amber::Router::Router.new
    getter time = Time.local

    def self.instance
      @@instance ||= new
    end

    def self.start
      instance.run
    end

    # Configure should probably be deprecated in favor of settings.
    def self.configure
      with self yield instance.settings
    end

    def self.pubsub_adapter
      instance.pubsub_adapter.instance
    end

    def self.router
      instance.router
    end

    def self.handler
      instance.handler
    end

    def initialize
    end

    def project_name
      @project_name ||= settings.name.gsub(/\W/, "_").downcase
    end

    def run
      thread_count = settings.process_count
      if Cluster.master? && thread_count > 1
        thread_count.times { Cluster.fork }
        sleep
      else
        start
      end
    end

    def start
      Log.info do
        "#{prefix} - " +
          "#{version} serving application " +
          "#{settings.name.capitalize.colorize.bold} at #{host_url}"
      end
      handler.prepare_pipelines

      if ssl_enabled?
        ssl_config = Launch::SSL.new(settings.ssl_key_file.not_nil!, settings.ssl_cert_file.not_nil!).generate_tls
        server.bind_tls Launch.settings.host, Launch.settings.port, ssl_config, settings.port_reuse
      else
        server.bind_tcp Launch.settings.host, Launch.settings.port, settings.port_reuse
      end

      Signal::INT.trap do
        Signal::INT.reset
        Log.info { "#{prefix} - Shutting down" }
        server.close
      end

      loop do
        begin
          Log.info do
            "#{prefix} - " +
              "Environment started in #{Launch.env.colorize(:yellow).bold}"
          end
          Log.info do
            "#{prefix} - " +
              "Startup Time #{start_up_time}"
          end
          listen
          break
        rescue e : IO::Error
          Log.error(exception: e) { "#{prefix} - Restarting..." }
          sleep 1
        end
      end
    end

    def version
      "Launch #{Launch::VERSION}".colorize(:light_cyan).bold
    end

    def host_url
      "#{scheme}://#{settings.host}:#{settings.port}".colorize(:light_cyan).mode(:underline).bold
    end

    def ssl_enabled?
      settings.ssl_key_file && settings.ssl_cert_file
    end

    def scheme
      ssl_enabled? ? "https" : "http"
    end

    def settings
      Launch.settings
    end

    private def elapsed_text(elapsed : Time::Span)
      Launch::Logger::Helpers.elapsed_text(elapsed)
    end

    private def prefix
      "API Server".colorize(:green)
    end

    private def start_up_time
      elapsed_text(Time.local - @time).colorize.bold
    end

    private def listen
      if Launch.settings.serverless
        spawn server.listen
      else
        server.listen
      end
    end

    private def server
      @server ||= HTTP::Server.new(handler)
    end
  end
end
