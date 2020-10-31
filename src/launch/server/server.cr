require "./cluster"
require "./ssl"

module Launch
  class Server
    include Launch::DSL::Server
    alias WebSocketAdapter = WebSockets::Adapters::RedisAdapter.class | WebSockets::Adapters::MemoryAdapter.class
    property pubsub_adapter : WebSocketAdapter = WebSockets::Adapters::MemoryAdapter
    getter handler = Pipe::Pipeline.new
    getter router = Amber::Router::Router.new

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
      time = Time.local
      Log.info {
        "#{version.colorize(:light_cyan)} serving application \"#{settings.name.capitalize}\"" +
          " at #{host_url.colorize(:light_cyan).mode(:underline)}"
      }
      handler.prepare_pipelines
      server = HTTP::Server.new(handler)

      if ssl_enabled?
        ssl_config = Launch::SSL.new(settings.ssl_key_file.not_nil!, settings.ssl_cert_file.not_nil!).generate_tls
        server.bind_tls Launch.settings.host, Launch.settings.port, ssl_config, settings.port_reuse
      else
        server.bind_tcp Launch.settings.host, Launch.settings.port, settings.port_reuse
      end

      Signal::INT.trap do
        Signal::INT.reset
        Log.info { "#{"Server".colorize(:green)} - Shutting down" }
        server.close
      end

      loop do
        begin
          Log.info { "#{"Server".colorize(:green)} - Environment started in #{Launch.env.colorize(:yellow)}." }
          Log.info { "#{"Server".colorize(:green)} - Startup Time #{elapsed_text(Time.local - time)}".colorize(:white) }
          server.listen
          break
        rescue e : IO::Error
          Log.error(exception: e) { "#{"Server".colorize(:green)} - Restarting..." }
          sleep 1
        end
      end
    end

    def version
      "Launch #{Launch::VERSION}"
    end

    def host_url
      "#{scheme}://#{settings.host}:#{settings.port}"
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

    def elapsed_text(elapsed : Time::Span)
      Launch::Logger::Helpers.elapsed_text(elapsed)
    end
  end
end
