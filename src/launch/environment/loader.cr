require "ecr/macros"

module Launch::Environment
  class Loader
    @path : String

    def initialize(path = "./config/credentials.yml.enc")
      @path = path
    end

    def credentials : YAML::Any
      YAML.parse(Support::FileEncryptor.read_as_string(credentials_settings_file))
    rescue e : File::NotFoundError
      raise Exceptions::Credentials.new
    end

    private def credentials_settings_file : String
      @credentials ||= File.expand_path(@path)
    end
  end
end
