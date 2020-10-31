require "colorize"

module Launch
  module Logger
    class Handler
      include HTTP::Handler
      # These constants are used here and in the PrettyLogFormatter to make sure
      # that the formatter looks for the right keys!
      REQUEST_START_KEYS = {
        method: "method",
        path:   "path",
      }

      REQUEST_END_KEYS = {
        status:   "status",
        duration: "duration",
      }

      delegate logger, to: Lucky

      def call(context)
        start = Time.monotonic

        # log_request_start(context) unless should_skip
        call_next(context)
        log_request_end(context, duration: Time.monotonic - start) # unless should_skip


      rescue e
        log_exception(context, Time.utc, e)
        raise e
      end

      private def log_request_start(context) : Nil
        Log.dexter.info do
          {
            REQUEST_START_KEYS[:method] => context.request.method,
            REQUEST_START_KEYS[:path]   => context.request.resource,
          }
        end
      end

      private def log_request_end(context, duration) : Nil
        Log.dexter.info do
          {
            REQUEST_END_KEYS[:status]   => context.response.status_code,
            REQUEST_END_KEYS[:duration] => Helpers.elapsed_text(duration),
          }
        end
      end

      private def log_exception(context : HTTP::Server::Context, time : Time, e : Exception) : Nil
        Log.error(exception: e) { "" }
      end
    end
  end
end
