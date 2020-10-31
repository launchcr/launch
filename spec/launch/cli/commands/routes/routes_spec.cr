require "../../../../spec_helper"
require "../../../../support/helpers/cli_helper"

require "cli/spec"

include CLIHelper
include Cli::Spec::Helper

module Launch::CLI
  extend Helpers
  describe "launch routes" do
    ENV["CRYSTAL_CLI_ENV"] = "test"
    context "in an `launch new` app with default options" do
      it "outputs routes with the default routes" do
        scaffold_app(TESTING_APP)
        output = ""
        MainCommand.run %w(routes) { |cmd| output = cmd.out.gets_to_end }
        output_lines = route_table_rows(output)

        headers = %w(Verb Controller Action Pipeline Scope) << "URI Pattern"
        headers.each do |header|
          output.should contain header
        end

        expected = "Launch::Controller::Static"
        output.should contain expected
        line = output_lines.find("") { |this_line| this_line.includes? expected }
        expectations = %w(get Launch::Controller::Static index static /*)
        expectations.each do |expectation|
          line.should contain expectation
        end

        expected = "HomeController"
        output.should contain expected
        line = output_lines.find("") { |this_line| this_line.includes? expected }
        expectations = %w(get HomeController index web /)
        expectations.each do |expectation|
          line.should contain expectation
        end
        cleanup
      end

      it "with the default routes as json" do
        output = ""
        scaffold_app(TESTING_APP)
        MainCommand.run ["routes", "--json"] { |cmd| output = cmd.out.gets_to_end }
        routes = route_table_from_json(output)

        expected = routes.find { |route| route.controller == "Launch::Controller::Static" }
        expected.nil?.should be_false
        if expected
          expected.verb.should eq "get"
          expected.uri_pattern.should eq "/*"
          expected.action.should eq "index"
          expected.pipeline.should eq "static"
          expected.scope.should eq ""
        end

        expected = routes.find { |route| route.controller == "HomeController" }
        expected.nil?.should be_false
        if expected
          expected.verb.should eq "get"
          expected.uri_pattern.should eq "/"
          expected.action.should eq "index"
          expected.pipeline.should eq "web"
          expected.scope.should eq ""
        end
        cleanup
      end

      it "outputs the websocket route" do
        output = ""
        scaffold_app(TESTING_APP)
        add_routes :api, %(websocket "/electric", ElectricSocket)
        MainCommand.run %w(routes) { |cmd| output = cmd.out.gets_to_end }
        output_lines = route_table_rows(output)

        expected = "websocket"
        output.should contain expected
        line = output_lines.find("") { |this_line| this_line.includes? expected }
        expectations = %w(websocket ElectricSocket web /electric)
        expectations.each do |expectation|
          line.should contain expectation
        end
        cleanup
      end
    end
  end
end
