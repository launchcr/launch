require "http"
require "log"
require "json"
require "colorize"
require "random/secure"
require "kilt"
require "redis"
require "compiled_license"
require "dexter"

require "./launch/version"
require "./launch/controller/**"
require "./launch/dsl/**"
require "./launch/exceptions/**"
require "./launch/extensions/**"
require "./launch/router/context"
require "./launch/logger/formatter"
require "./launch/pipes/**"
require "./launch/server/**"
require "./launch/validators/**"
require "./launch/websockets/**"
require "./launch/environment/loader"
require "./launch/environment"

module Launch
  include Launch::Environment
  Loader.new.load_dotenv_files # Ensure .env files are loaded
end
