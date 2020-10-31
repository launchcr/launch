require "ecr/macros"

module Launch::Environment
  class Loader
    def initialize(
      @environment : String = Launch.env.to_s,
      @path : String = Launch.environment_path
    )
    end

    def settings : Settings
      environment_files = Hash(String, String).new
      {{ run("./file_loader", "/config/environments") }}
      Settings.from_yaml(environment_files[@environment])
    rescue e : KeyError
      raise Exceptions::Environment.new(@environment)
    end

    def credentials : YAML::Any
      YAML.parse(Support::FileEncryptor.read_as_string(credentials_settings_file))
    rescue e : Exception
      puts e
      # TODO
      raise "No credentials.yml.enc file"
    end

    private def credentials_settings_file : String
      @credentials ||= File.expand_path("./config/credentials.yml.enc")
    end
  end
end
