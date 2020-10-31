# :nodoc:
module Jennifer
  # Jennifer does not expose any method to configure with a string.
  # All config entries expect a path. Because Launch allows ecr in the database.yml
  # file, we need to extend jennifer. These methods copy the current config
  # methods except we bypass the `File.read` portion and go straight to parsing the YAML.
  # :nodoc:
  class Config
    def self.parse(*args, **opts)
      config.parse(*args, **opts)
    end

    def parse(data : String, env : Symbol = :development)
      parse(data, env.to_s)
    end

    # ditto
    def parse(data : String, env : String)
      parse(data) { |document| document[env] }
    end

    # Reads configurations from the file with given `string`.
    def parse(data : String)
      source = yield YAML.parse(data)
      from_yaml(source)
    end
  end
end
