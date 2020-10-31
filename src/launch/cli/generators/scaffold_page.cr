module Launch::CLI
  class ScaffoldPage < Launch::CLI::Generator
    directory "#{__DIR__}/../templates/scaffold/page"

    def initialize(name, fields)
      super(name, fields)
      add_timestamp_fields
      # TODO
      # add_static_routes
    end
  end
end
