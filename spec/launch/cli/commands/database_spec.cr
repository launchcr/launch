require "../../../spec_helper"
require "../../../support/helpers/cli_helper"
require "../../../support/fixtures/cli_fixtures"

include CLIHelper
include CLIFixtures

module Launch::CLI
  describe "database" do
    ENV["LAUNCH_ENV"] = "test"

    describe "sqlite" do
      context ENV["LAUNCH_ENV"] do
        it "has connection settings in config/environments/env.yml" do
          config_yml = prepare_test_app
          config_yml["database"].should eq "sqlite3"
          cleanup
        end

        it "does not create the database when db create" do
          prepare_test_app
          db_filename = "./#{TEST_APP_NAME}_development.db"
          File.exists?(db_filename).should be_false
          cleanup
        end

        it "creates the database when db migrate & deletes on drop" do
          prepare_test_app_with_deps

          MainCommand.run ["generate", "model", "-y", "Post"]
          MainCommand.run ["db", "migrate"]

          db_filename = "./#{ENV["LAUNCH_ENV"]}_#{TEST_APP_NAME}_db"

          File.exists?(db_filename).should be_true
          File.info(db_filename).size.should_not eq 0

          MainCommand.run ["db", "drop"]

          File.exists?(db_filename).should be_false
          cleanup
        end
      end
    end

    describe "postgres" do
      context ENV["LAUNCH_ENV"] do
        it "has #{ENV["LAUNCH_ENV"]} connection settings" do
          scaffold_app("#{TESTING_APP}", "-d", "pg")
          config_yml = launch_yml
          config_yml["database"].should eq "postgres"
          cleanup
        end
      end
    end
  end
end
