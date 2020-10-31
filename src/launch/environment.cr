require "./environment/env"
require "./environment/loader"
require "./environment/logging"
require "./environment/settings"
require "./support/file_encryptor"

module Launch::Environment
  macro included
    @@settings : Settings = Settings.new
    @@credentials : YAML::Any?

    def self.settings
      @@settings
    end

    def self.credentials
      @@credentials ||= Loader.new(env.to_s, path).credentials
    end

    def self.env
      @@env ||= Env.new
    end
  end
end
