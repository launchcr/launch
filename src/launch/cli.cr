require "log"
require "cli"
require "./version"
require "./exceptions/*"
require "./environment"
require "./cli/commands"
require "./logger/formatter"

backend = Log::IOBackend.new(STDOUT)
backend.formatter = Launch::Logger::Formatter.proc
Log.dexter.configure(:info, backend)

Launch::CLI::MainCommand.run ARGV
