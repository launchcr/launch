require "./environment/env"
require "./environment/loader"
require "./environment/logging"
require "./environment/settings"
require "./support/file_encryptor"

module Launch::Environment
  macro included
    @@settings : Settings?
    @@credentials : YAML::Any?

    def self.settings : Settings
      @@settings ||= Settings.new
    end

    def self.credentials : YAML::Any
      @@credentials ||= Loader.new.credentials
    end

    def self.env : Env
      @@env ||= Env.new
    end
  end
end
