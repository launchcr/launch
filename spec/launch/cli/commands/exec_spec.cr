require "../../../spec_helper"
require "../../../support/helpers/cli_helper"

include CLIHelper

module Launch::CLI
  describe MainCommand::Exec do
    context "within project" do
      Spec.before_suite do
        scaffold_app(TESTING_APP)
        # system("shards") # I don't believe this is needed
      end

      Spec.after_suite do
        cleanup
      end

      pending "executes one-liners from the first command-line argument"
      # it "executes one-liners from the first command-line argument" do
      #   expected_result = "3000\n"
      #   MainCommand.run(["exec", "Launch.settings.port", "--editor", "nano"])
      #   logs = Dir["./tmp/*_console_result.log"].sort

      #   File.read(logs.last?.to_s).should eq expected_result
      # end

      pending "executes multi-lines from the command-line argument"
      # it "executes multi-lines from the command-line argument" do
      #   expected_result = "one\ntwo\nthree\nnil\n"
      #   code = <<-CRYSTAL
      #   %w(one two three).each do |item|
      #     puts item
      #   end
      #   CRYSTAL
      #   MainCommand.run(["exec", code])
      #   logs = Dir["./tmp/*_console_result.log"].sort

      #   File.read(logs.last?.to_s).should eq expected_result
      # end

      pending "executes a .cr file from the first command-line argument"
      # it "executes a .cr file from the first command-line argument" do
      #   File.write "launch_exec_spec_test.cr", "puts([:a] + [:b])"
      #   MainCommand.run(["exec", "launch_exec_spec_test.cr", "-e", "tail"])
      #   logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
      #   File.read(logs.last?.to_s).should eq "[:a, :b]\n"
      #   File.delete("launch_exec_spec_test.cr")
      # end

      pending "opens editor and executes .cr file on close"
      # it "opens editor and executes .cr file on close" do
      #   MainCommand.run(["exec", "-e", "echo 'puts 1000' > "])
      #   logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
      #   File.read(logs.last?.to_s).should eq "1000\n"
      # end

      pending "copies previous run into new file for editing and runs it returning results"
      # it "copies previous run into new file for editing and runs it returning results" do
      #   MainCommand.run(["exec", "1337"])
      #   MainCommand.run(["exec", "-e", "tail", "-b", "1"])
      #   logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
      #   File.read(logs.last?.to_s).should eq "1337\n"
      # end
    end

    context "outside of project" do
      pending "executes outside of project but without including project"
      # it "executes outside of project but without including project" do
      #   expected_result = ":hello\n"
      #   MainCommand.run(["exec", ":hello"])
      #   logs = `ls tmp/*_console_result.log`.strip.split(/\s/).sort
      #   File.read(logs.last?.to_s).should eq expected_result
      # end
    end
  end
end
