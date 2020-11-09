require "./environment/env"
require "./environment/loader"
require "./environment/logging"
require "./environment/settings"
require "./support/file_encryptor"

module Launch::Environment
  macro included
    @@settings : Settings?
    Loader.new.load_dotenv_files # Ensure .env files are loaded

    def self.settings : Settings
      @@settings ||= Settings.new
    end

    def self.env : Env
      @@env ||= Env.new
    end
  end
end
