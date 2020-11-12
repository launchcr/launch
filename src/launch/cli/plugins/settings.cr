require "yaml"
require "yaml_mapping"

module Launch::CLI::Plugins
  class Settings
    alias RouteType = Hash(String, Hash(String, Array(String)))

    YAML.mapping(
      routes: {
        type:    RouteType,
        default: {"pipelines" => Hash(String, Array(String)).new},
      }
    )
  end
end
