require "../plugins/plugin"

module Launch::CLI
  class_property color = true

  class MainCommand < ::Cli::Supercommand
    command "pl", aliased: "plugin"

    class Plugin < Command
      class Options
        bool ["-u", "--uninstall"], desc: "uninstall plugin", default: false
        arg "name", desc: "name of the shard", required: true
        help
      end

      class Help
        header "Generates the named plugin from the given plugin template"
        caption "Generates application plugin based on templates"
      end

      def run
        uninstall_plugin?
        ensure_name_argument!

        if Launch::CLI::Plugins::Plugin.can_generate?(args.name)
          template = Launch::CLI::Plugins::Plugin.new(args.name, "./src/plugins")
          template.generate (options.uninstall? ? "uninstall" : "install")
        end
      end

      private def ensure_name_argument!
        unless args.name?
          error "Parsing Error: The NAME argument is required."
          exit! error: true
        end
      end

      private def uninstall_plugin?
        if options.uninstall?
          error "Invalid plugin action, 'uninstalling' is currently not supported."
          exit! error: true
        end
      end
    end
  end
end
