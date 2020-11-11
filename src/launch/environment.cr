require "./environment/env"
require "./environment/logging"
require "./environment/settings"

module Launch::Environment
  macro included
    @@settings : Settings?

    def self.settings : Settings
      @@settings ||= Settings.new
    end

    def self.env : Env
      @@env ||= Env.new
    end
  end
end
