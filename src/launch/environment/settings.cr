require "yaml"
require "yaml_mapping"

module Launch::Environment
  class Settings
    alias SettingValue = String | Int32 | Bool | Nil
    alias CredentialsType = String | YAML::Any

    @smtp_settings : SMTPSettings?

    getter database_url : String = ""
    getter host : String = "0.0.0.0"
    getter redis_url : String = "redis://localhost:6379"
    getter secret_key_base : String = Random::Secure.urlsafe_base64(32)
    getter ssl_key_file : String? = nil
    getter ssl_cert_file : String? = nil

    setter session : Hash(String, Int32 | String)
    setter smtp : Hash(String, SettingValue)

    property name : String = "Launch_App"
    property port : Int32 = 3001
    property port_reuse : Bool = true
    property process_count : Int32 = 1
    property logging : Logging::OptionsType = Logging::DEFAULTS
    property auto_reload : Bool = true
    property session : Hash(String, Int32 | String) = {
      "key"     => "launch.session",
      "store"   => "signed_cookie",
      "expires" => 0,
    }
    property pipes : Hash(String, Hash(String, Hash(String, SettingValue))) = {
      "static" => {
        "headers" => {} of String => SettingValue,
      },
    }

    struct SMTPSettings
      property host = "127.0.0.1"
      property port = 1025
      property enabled = false
      property username = ""
      property password = ""
      property tls = false

      def self.from_hash(settings = {} of String => SettingValue) : self
        i = new
        i.host = settings["host"]? ? settings["host"].as String : i.host
        i.port = settings["port"]? ? settings["port"].as Int32 : i.port
        i.enabled = settings["enabled"]? ? settings["enabled"].as Bool : i.enabled
        i.username = settings["username"]? ? settings["username"].as String : i.username
        i.password = settings["password"]? ? settings["password"].as String : i.password
        i.tls = settings["tls"]? ? settings["tls"].as Bool : i.tls
        i
      end
    end

    def initialize
      @smtp = Hash(String, SettingValue).new
      @smtp["enabled"] = false
    end

    def smtp : SMTPSettings
      @smtp_settings ||= SMTPSettings.from_hash @smtp
    end

    def session
      {
        :key     => @session["key"].to_s,
        :store   => session_store,
        :expires => @session["expires"].to_i,
      }
    end

    def session_store
      case @session["store"].to_s
      when "signed_cookie" then :signed_cookie
      when "redis"         then :redis
      else                      "encrypted_cookie"
      :encrypted_cookie
      end
    end

    def logging
      @_logging ||= Logging.new(@logging)
    end

    def secret_key_base=(secret_key_base : CredentialsType)
      @secret_key_base = secret_key_base.to_s
    end

    def host=(host : CredentialsType)
      @host = host.to_s
    end

    def redis_url=(redis_url : CredentialsType)
      @redis_url = redis_url.to_s
    end

    def ssl_key_file=(ssl_key_file : CredentialsType?)
      @ssl_key_file = (ssl_key_file ? ssl_key_file.to_s : nil)
    end

    def ssl_cert_file=(ssl_cert_file : CredentialsType?)
      @ssl_cert_file = (ssl_cert_file ? ssl_cert_file.to_s : nil)
    end

    def database_url=(database_url : CredentialsType)
      @database_url = database_url.to_s
    end
  end
end
