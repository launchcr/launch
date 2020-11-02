module Launch::CLI
  Log = ::Log.for("database")

  class MainCommand < ::Cli::Supercommand
    command "db", aliased: "database"

    # Handles database operations. Due to how jennifer migrations work, instead
    # of calling methods directly, Process.run is utilized. A sam.cr file exists
    # in the users project which is ran with the proper commands.
    class Database < Command
      command_name "database"
      MIGRATIONS_DIR        = "./db/migrations"
      CREATE_SQLITE_MESSAGE = "For sqlite3, the database will be created during the first migration."

      class Options
        arg_array "commands", desc: "drop create migrate rollback redo status version seed"
        string ["-s", "--step"], desc: "how many steps to migrate or rollback", default: ""
        string ["-v", "--version"], desc: "database version to rollback too", default: ""
        bool "--no-color", desc: "disable colored output", default: false
        help
      end

      class Help
        header <<-EOS
          Performs database migrations and maintenance tasks.

        Commands:
          drop      drops the database
          create    creates the database
          migrate   migrate the database to the most recent version available or by steps
          rollback  roll back the database version by 1
          load      loads the database with a schema
          version   print the current version of the database
          seed      initialize the database with seed data
          setup     runs create, migrate and seed
        EOS
        caption "performs database migrations and maintenance tasks"
      end

      def run
        CLI.toggle_colors(options.no_color?)
        process_commands(args.commands)
      rescue e : Exception
        exit! e.message, error: true
      end

      private def process_commands(commands)
        File.write(sam_file_directory, sam_file_content) unless File.exists?(sam_file_directory)
        commands.each do |command|
          case command
          when "drop"
            drop_database
          when "create"
            create_database
          when "migrate"
            migrate
          when "seed"
            seed
          when "rollback"
            rollback
          when "load"
            schema_load
          when "setup"
            setup
          when "version"
            version
          else
            # TODO: Undecided if Launch should leave the file
            # in the users directory or remove it. There is
            # no major performance hit for generating it at runtime.
            # File.delete("#{sam_file_directory}")
            exit! help: true, error: false
          end
        end
        # File.delete("#{sam_file_directory}")
      end

      private def migrate
        info "Migrating Database"
        if options.step.empty?
          Helpers.run("crystal #{sam_file_directory} db:migrate", wait: true, shell: true)
        else
          Helpers.run("crystal #{sam_file_directory} db:step #{options.step}", wait: true, shell: true)
        end
      end

      private def drop_database
        info "Dropping database"
        Helpers.run("crystal #{sam_file_directory} db:drop", wait: true, shell: true)
      end

      private def create_database
        info "Creating database"
        Helpers.run("crystal #{sam_file_directory} db:create", wait: true, shell: true)
      end

      private def seed
        info "Seeding database"
        Helpers.run("crystal db/seeds.cr", wait: true, shell: true)
        info "Database has been seeded"
      end

      private def rollback
        if !options.version.empty?
          info "Rolling back database to version #{options.version}"
          Helpers.run("crystal #{sam_file_directory} db:rollback v=#{options.version}", wait: true, shell: true)
        elsif options.step.empty? || options.step == "1"
          info "Rolling back database 1 step"
          Helpers.run("crystal #{sam_file_directory} db:rollback 1", wait: true, shell: true)
        else
          info "Rolling back database #{options.step} steps"
          Helpers.run("crystal #{sam_file_directory} db:rollback #{options.step}", wait: true, shell: true)
        end
      end

      private def schema_load
        info "Loading Schema"
        Helpers.run("crystal #{sam_file_directory} db:schema:load #{options.step}", wait: true, shell: true)
      end

      private def setup
        create_database
        migrate
        seed
      end

      private def version
        Helpers.run("crystal #{sam_file_directory} db:version", wait: true, shell: true)
      end

      private def sam_file_content
        "# This file is autogenerated.\n" +
          "# It is used for Jennifer database operations.\n" +
          "# Please do not modify.\n\n" +
          "require \"launch\"\n" +
          "require \"./config/settings\"\n" +
          "require \"./config/jennifer\"\n" +
          "require \"./db/migrations/*\"\n" +
          "require \"sam\"\n" +
          "require \"jennifer/sam\"\n" +
          "load_dependencies \"jennifer\"\n" +
          "Sam.help"
      end

      private def sam_file_directory
        "#{Dir.current}/sam.cr"
      end
    end
  end
end
