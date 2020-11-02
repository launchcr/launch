module Launch
  module Pipe
    class Logger < Base
      def initialize(
        @filter : Array(String) = log_config.filter,
        @skip : Array(String) = log_config.skip
      )
      end

      def call(context : HTTP::Server::Context) : HTTP::Server::Context
        time = Time.utc
        call_next(context)

        status = context.response.status_code
        elapsed = elapsed_text(Time.utc - time)

        request(context, time, elapsed, status)

        log_others(context)
        context
      end

      private def request(
        context : HTTP::Server::Context,
        time : Time,
        elapsed : String,
        status : Int32
      ) : Nil
        msg = String.build do |str|
          str << "Status: #{http_status(status)} "
          str << "Method: #{method(context)} "
          str << "Pipeline: #{pipeline(context)} "
          str << "Format: #{format(context)}"
        end

        log "Started #{colorized_time(time)}", "Request"
        log msg, "Request"
        log "Requested Url: #{request_url(context)}", "Request"
        log "Time Elapsed: #{colorized_elapsed(elapsed)}", "Request"
      end

      private def log_others(context : HTTP::Server::Context)
        log_other(context.request.headers, "Headers")
        log_other(context.request.cookies, "Cookies", :light_blue)
        log_other(context.params, "Params", :light_blue)
        log_other(context.session, "Session", :light_yellow)
      end

      private def log_other(other, name : String, color = :light_cyan)
        other.to_h.each do |key, val|
          next if @skip.includes? key

          if @filter.includes? key.to_s
            log "#{key}: #{filtered}", name, color
          else
            log "#{key}: #{val.colorize(color).bold}", name, color
          end
        end
      end

      private def method(context : HTTP::Server::Context) : Colorize::Object(String)
        context.request.method.colorize(:light_red).to_s.colorize.bold
      end

      private def http_status(status) : Colorize::Object(String)
        Launch::Logger::Helpers.colored_http_status(status).colorize.bold
      end

      private def pipeline(context : HTTP::Server::Context) : Colorize::Object(Symbol)
        context.valve.colorize(:magenta).bold
      end

      private def format(context : HTTP::Server::Context) : Colorize::Object(String)
        context.format.to_s.colorize(:magenta).bold
      end

      def elapsed_text(elapsed : Time::Span) : String
        Launch::Logger::Helpers.elapsed_text(elapsed)
      end

      private def colorized_time(time : Time) : Colorize::Object(Time)
        time.colorize(:magenta).bold
      end

      private def request_url(context : HTTP::Server::Context) : Colorize::Object(String)
        context.requested_url.colorize(:magenta).bold
      end

      private def colorized_elapsed(elapsed : String) : Colorize::Object(String)
        elapsed.colorize(:magenta).bold
      end

      private def filtered : Colorize::Object(String)
        "FILTERED".colorize(:white).mode(:underline).bold
      end

      private def log(msg : String, prog : String, color = :magenta)
        Log.debug { "#{prog.colorize(color)} - #{msg}" }
      end

      private def log_config
        Launch.settings.logging
      end
    end
  end
end
