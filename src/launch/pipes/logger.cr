module Launch
  module Pipe
    class Logger < Base
      Colorize.enabled = Launch.settings.logging.colorize

      def initialize(@filter : Array(String) = log_config.filter,
                     @skip : Array(String) = log_config.skip)
      end

      def call(context : HTTP::Server::Context)
        time = Time.utc
        call_next(context)
        status = context.response.status_code
        elapsed = elapsed(Time.utc - time)
        request(context, time, elapsed, status, :magenta)
        log_other(context.request.headers, "Headers")
        log_other(context.request.cookies, "Cookies", :light_blue)
        log_other(context.params, "Params", :light_blue)
        log_other(context.session, "Session", :light_yellow)
        context
      end

      private def request(context, time, elapsed, status, color = :magenta)
        msg = String.build do |str|
          str << "Status: #{http_status(status)} Method: #{method(context)}"
          str << " Pipeline: #{context.valve.colorize(color)} Format: #{context.format.colorize(color)}"
        end
        log "Started #{time.colorize(color)}", "Request", color
        log msg, "Request", color
        log "Requested Url: #{context.requested_url.colorize(color)}", "Request", color
        log "Time Elapsed: #{elapsed.colorize(color)}", "Request", color
      end

      private def log_other(other, name, color = :light_cyan)
        other.to_h.each do |key, val|
          next if @skip.includes? key
          if @filter.includes? key.to_s
            log "#{key}: #{"FILTERED".colorize(:white).mode(:underline)}", name, color
          else
            log "#{key}: #{val.colorize(color)}", name, color
          end
        end
      end

      private def method(context)
        context.request.method.colorize(:light_red).to_s
      end

      private def http_status(status)
        Launch::Logger::Helpers.colored_http_status(status)
      end

      def elapsed(elapsed : Time::Span)
        Launch::Logger::Helpers.elapsed_text(elapsed)
      end

      private def log(msg, prog, color = :white)
        Log.for(prog).debug { "#{prog.colorize(color)} - #{msg}" }
      end

      private def log_config
        Launch.settings.logging
      end
    end
  end
end
