require "./environment/env"
require "./environment/loader"
require "./environment/logging"
require "./environment/settings"
require "./support/file_encryptor"

module Launch::Environment
  macro included
    class_property path : String = "./config/environments/"
    @@settings : Settings?
    @@credentials : YAML::Any?

    def self.settings
      @@settings ||= Loader.new(env.to_s, path).settings
    end

    def self.credentials
      @@credentials ||= Loader.new(env.to_s, path).credentials
    end

    def self.env=(env : String)
      @@env = Env.new(env.to_s)
      @@settings = Loader.new(env, path).settings
    end

    def self.env
      @@env ||= Env.new
    end
  end
end
