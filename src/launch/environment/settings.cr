require "yaml"
require "yaml_mapping"

module Launch::Environment
  class Settings
    alias SettingValue = String | Int32 | Bool | Nil
    alias CredentialsType = String | YAML::Any

    @smtp_settings : SMTPSettings?

    getter host : String = "0.0.0.0"
    getter secret_key_base : String = Random::Secure.urlsafe_base64(32)
    getter ssl_key_file : String? = nil
    getter ssl_cert_file : String? = nil

    getter database_url : String? = nil
    getter database_host : String = "."
    getter database_user : String = ""
    getter database_password : String = ""
    getter database_adapter : String = "sqlite3"
    getter migration_type : String = "crystal"
    getter migration_file_path : String = "db/migrations"

    getter redis_url : String = "redis://localhost:6379"

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

    def ssl_key_file=(ssl_key_file : CredentialsType?)
      @ssl_key_file = (ssl_key_file ? ssl_key_file.to_s : nil)
    end

    def ssl_cert_file=(ssl_cert_file : CredentialsType?)
      @ssl_cert_file = (ssl_cert_file ? ssl_cert_file.to_s : nil)
    end

    def database_url=(database_url : CredentialsType?)
      @database_url = database_url.to_s
    end

    def database_host=(database_host : CredentialsType)
      @database_host = database_host.to_s
    end

    def database_user=(database_user : CredentialsType)
      @database_user = database_user.to_s
    end

    def database_password=(database_password : CredentialsType)
      @database_password = database_password.to_s
    end

    def database_adapter=(database_adapter : CredentialsType)
      @database_adapter = database_adapter.to_s
    end

    def migration_type=(migration_type : CredentialsType)
      @migration_type = migration_type.to_s
    end

    def database_host=(database_host : CredentialsType)
      @migration_file_path = migration_file_path.to_s
    end

    def redis_url=(redis_url : CredentialsType)
      @redis_url = redis_url.to_s
    end
  end
end
