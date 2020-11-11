require "dotenv"

module Launch::Environment
  class Loader
    def initialize(@path = ".env.#{Launch.env}")
    end

    def load_dotenv_files
      Dotenv.load(path: @path)
      Log.debug { "API Server - #{@path} was loaded" }
    rescue e : File::NotFoundError
      load_dotenv
    end

    private def load_dotenv
      Dotenv.load
      Log.debug { "API Server - .env was loaded" }
    rescue e : File::NotFoundError
      Log.debug { "API Server - No environment variables to load" }
      false
    end
  end
end
