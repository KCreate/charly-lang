require "./charly/syntax/parser.cr"
require "./charly/interpreter/interpreter.cr"
require "./charly/gc_warning.cr"
require "option_parser"

module Charly

  arguments = [] of String
  flags = [] of String
  filename = ""

  available_flags = <<-FLAGS

  Flags:
      ast                              Display the AST of the userfile
      tokens                           Display tokens of the userfile
      lint                             Don't execute after parsing (linting)
  FLAGS

  # Check if $CHARLYDIR is set
  unless ENV.has_key? "CHARLYDIR"
    puts "$CHARLYDIR is not configured!"
    exit 1
  end

  OptionParser.parse! do |opts|
    opts.banner = "Usage: charly [filename] [flags] [arguments]"
    opts.on("-f FLAG", "--flag FLAG", "Set a flag") { |flag|
      flags << flag
    }
    opts.on("-h", "--help", "Print this help message") {
      puts opts
      puts available_flags
      exit
    }
    opts.on("-v", "--version", "Prints the version number") {
      puts "0.0.1"
      exit
    }
    opts.invalid_option {} # Ignore
    opts.unknown_args do |before_dash|
      before_dash = before_dash.to_a
      if before_dash.size == 0
        before_dash.unshift "repl"
      end
      filename = before_dash.shift
      arguments = before_dash

      # If the filename is repl, expand the path to the repl.charly file
      if filename == "repl"
        filename = ENV["CHARLYDIR"] + "/src/std/repl.charly"
      end
    end
  end

  begin

    # Create some needed scopes
    prelude_scope = Scope.new
    user_scope = Scope.new(prelude_scope)
    interpreter = Interpreter.new(user_scope, prelude_scope)

    # Insert ARGV, FLAGS and ENV
    c_argv = [] of BaseType
    c_iflags = [] of BaseType
    arguments.each do |arg|
      c_argv << TString.new arg
    end
    flags.each do |arg|
      c_iflags << TString.new arg
    end

    prelude_scope.write("ARGV", TArray.new(c_argv), Flag::INIT | Flag::CONSTANT)
    prelude_scope.write("IFLAGS", TArray.new(c_iflags), Flag::INIT | Flag::CONSTANT)

    env_object = TObject.new
    ENV.each do |key, value|
      env_object.data.write(key, TString.new(value), Flag::INIT | Flag::CONSTANT)
    end
    prelude_scope.write("ENV", env_object, Flag::INIT | Flag::CONSTANT)

    # Parse and run the prelude
    start = Time.now.epoch_ms
    prelude = Parser.create(File.open(PRELUDE_PATH), PRELUDE_PATH)
    puts "Prelude parse took: #{Time.now.epoch_ms - start}"

    start = Time.now.epoch_ms
    interpreter.exec_program prelude, prelude_scope
    puts "Prelude exec took: #{Time.now.epoch_ms - start}"

    # Parse and run the user file
    start = Time.now.epoch_ms
    program = Parser.create(File.open(filename), filename)
    puts "Userfile parse took: #{Time.now.epoch_ms - start}"

    start = Time.now.epoch_ms
    interpreter.exec_program program, user_scope
    puts "Userfile exec took: #{Time.now.epoch_ms - start}"
  rescue e : UserException
    puts e
    exit 1
  rescue e : Exception
    puts e
    exit 1
  end
end
