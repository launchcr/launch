require "../../../spec_helper"
require "../../../support/helpers/cli_helper"
require "../../../support/fixtures/cli_fixtures"

include CLIHelper
include CLIFixtures

module Launch::CLI
  describe "launch generate" do
    before_each do
      scaffold_app(TESTING_APP)
    end

    after_each do
      cleanup
    end

    ENV["LAUNCH_ENV"] = "test"
    camel_case = "PostComment"
    snake_case = "post_comment"
    incorrect_case = "Post_comment"
    display = "PostComment"
    class_definition_prefix = "class #{camel_case}"
    spec_definition_prefix = "describe #{camel_case}"

    it "generates controller with correct verbs and actions" do
      MainCommand.run %w(generate controller -y animal)
      route_file = File.read("./config/routes.cr")

      # generates controller with correct verbs and actions"
      generated_controller = "./src/controllers/animal_controller.cr"
      File.read(generated_controller).should eq expected_animal_controller

      route_file.includes?("resources \"/animals\", AnimalController, except: [:new, :edit]").should be_true

      # "follows naming conventions for all files and class names"
      [camel_case, snake_case].each do |arg|
        MainCommand.run ["generate", "controller", "-y", arg]
        filename = snake_case
        src_filepath = "./src/controllers/#{filename}_controller.cr"
        spec_filepath = "./spec/controllers/#{filename}_controller_spec.cr"

        File.exists?(src_filepath).should be_true
        File.exists?(spec_filepath).should be_true
        File.read(src_filepath).should contain class_definition_prefix
        File.read(spec_filepath).should contain spec_definition_prefix
        File.delete(src_filepath)
        File.delete(spec_filepath)
      end
    end

    # pending("generates model correctly")
    it "generates model correctly" do
      MainCommand.run %w(
        generate model -y Post title:string body:text published:bool likes:int user:references
      )

      # "creates Post migration file"
      generated_migration = Dir["./db/migrations/*_create_post.cr"].first
      File.read(generated_migration).should eq expected_post_model_migration

      # "generates Post model spec file"
      generated_spec = "./spec/models/post_spec.cr"
      File.read(generated_spec).should eq expected_post_model_spec

      # "generates Post model"
      generated_model = "src/models/post.cr"
      File.read(generated_model).should eq expected_post_model
    end

    it "generates scaffold correctly" do
      # "follows naming conventions for all files and class names"
      [camel_case, snake_case].each do |arg|
        MainCommand.run ["generate", "scaffold", "-y", arg, "name:string"]

        File.exists?("./spec/models/#{snake_case}_spec.cr").should be_true
        File.exists?("./src/models/#{snake_case}.cr").should be_true
        File.exists?("./spec/controllers/#{snake_case}_controller_spec.cr").should be_true
        File.exists?("./src/controllers/#{snake_case}_controller.cr").should be_true
        File.exists?("./src/components/#{camel_case}/Form.tsx").should be_true
        File.exists?("./src/pages/#{snake_case}s/[id]/edit.tsx").should be_true
        File.exists?("./src/pages/#{snake_case}s/index.tsx").should be_true
        File.exists?("./src/pages/#{snake_case}s/new.tsx").should be_true
        File.exists?("./src/pages/#{snake_case}s/[id]/index.tsx").should be_true
        File.read("./spec/models/#{snake_case}_spec.cr").should contain spec_definition_prefix
        File.read("./src/models/#{snake_case}.cr").should contain class_definition_prefix
        File.read("./spec/controllers/#{snake_case}_controller_spec.cr").should contain spec_definition_prefix
        File.read("./src/controllers/#{snake_case}_controller.cr").should contain class_definition_prefix
        File.read("./src/components/#{camel_case}/Form.tsx").should contain snake_case
        File.read("./src/pages/#{snake_case}s/[id]/edit.tsx").should contain display
        File.read("./src/pages/#{snake_case}s/index.tsx").should contain display
        File.read("./src/pages/#{snake_case}s/new.tsx").should contain (display + "New")
        File.read("./src/pages/#{snake_case}s/[id]/index.tsx").should contain snake_case
        File.read("./config/routes.cr").should contain "#{camel_case}Controller"
        File.read("./config/routes.cr").should_not contain "#{incorrect_case}Controller"
      end
    end

    it "generates migrations correctly" do
      # "follows naming conventions for all files"
      [camel_case, snake_case].each do |arg|
        MainCommand.run ["generate", "migration", "-y", arg]

        migration_filename = Dir.entries("./db/migrations").sort.last
        migration_filename.should contain snake_case
        File.delete("./db/migrations/#{migration_filename}")
      end
    end

    it "generates mailers correctly" do
      # "follows naming conventions for all files and class names"
      [camel_case, snake_case].each do |arg|
        MainCommand.run ["generate", "mailer", "-y", arg]
        filename = snake_case
        src_filepath = "./src/mailers/#{filename}_mailer.cr"

        File.exists?(src_filepath).should be_true
        File.read(src_filepath).should contain class_definition_prefix
        File.delete(src_filepath)
      end
    end

    it "generatres socket correctly" do
      struct_definition_prefix = "struct #{camel_case}"

      # "follows naming conventions for all files and class names"
      [camel_case, snake_case].each do |arg|
        MainCommand.run ["generate", "socket", "-y", arg]
        filename = snake_case
        src_filepath = "./src/sockets/#{filename}_socket.cr"

        File.exists?(src_filepath).should be_true
        File.read(src_filepath).should contain struct_definition_prefix
        File.delete(src_filepath)
      end
    end

    it "generates channels correctly" do
      # "follows naming conventions for all files and class names"
      [camel_case, snake_case].each do |arg|
        MainCommand.run ["generate", "channel", "-y", arg]
        filename = snake_case
        src_filepath = "./src/channels/#{filename}_channel.cr"

        File.exists?(src_filepath).should be_true
        File.read(src_filepath).should contain class_definition_prefix
        File.delete(src_filepath)
      end
    end
  end
end
