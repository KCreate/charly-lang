require "./charly/syntax/parser.cr"
require "./charly/interpreter/visitor.cr"
require "./charly/interpreter/prelude.cr"
require "./charly/gc_warning.cr"
require "./charly/config.cr"
require "./charly/visitors/DumpVisitor.cr"
require "./charly/visitors/DotDumpVisitor.cr"
require "option_parser"

# :nodoc:
def missing_file(filename)
  puts "Cannot load file: #{filename}"
  exit 1
end

module Charly

  arguments = [] of String
  flags = [] of String
  filename = ""

  available_flags = String.build do |io|
    io.puts <<-FLAGS

    Flags:
        ast                              Display the AST of the userfile
        tokens                           Display tokens of the userfile
        lint                             Don't execute after parsing (linting)
    FLAGS

    io.puts ""
    io.puts "#{Internals::Methods::METHODS.size} internal methods are loaded"
  end

  # Check if $CHARLYDIR is set
  unless ENV.has_key? "CHARLYDIR"
    puts "$CHARLYDIR is not configured!"
    exit 1
  end

  # Chack that the prelude exists
  unless File.exists?(PRELUDE_PATH) && File.readable?(PRELUDE_PATH)
    missing_file(PRELUDE_PATH)
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
      puts Config.description
      exit
    }

    opts.on("--license", "Prints the license") {
      puts Config::LICENSE
      exit
    }

    opts.invalid_option { } # Ignore

    opts.unknown_args do |before_dash|
      before_dash = before_dash.to_a
      if before_dash.size == 0
        before_dash.unshift "repl"
      end
      filename = before_dash.shift
      arguments = before_dash

      # If the filename is repl, expand the path to the repl.ch file
      if filename == "repl"
        filename = ENV["CHARLYDIR"] + "/src/std/repl.ch"
      end
    end
  end

  # Check that the userfile exists
  unless File.exists?(filename) && File.readable?(filename)
    missing_file(filename)
  end

  begin
    # Parse the userfile
    user_program = Parser.create(File.open(filename), filename)

    if flags.includes? "tokens"
      user_program.tokens.each do |token|
        puts token
      end
    end

    if flags.includes? "ast"
      dump_visitor = DumpVisitor.new
      output = IO::Memory.new
      user_program.tree.accept dump_visitor, output
      STDOUT.puts output.to_s.strip
    end

    if flags.includes? "dotdump"
      DotDumpVisitor.new.render(user_program.tree, STDOUT)
    end

    prelude_scope = PreludeLoader.load(PRELUDE_PATH, arguments, flags)
    user_scope = Scope.new(prelude_scope)
    visitor = Visitor.new(user_scope, prelude_scope)

    unless flags.includes? "lint"
      prelude_program = Parser.create(File.open(PRELUDE_PATH), PRELUDE_PATH)
      visitor.visit_program prelude_program, prelude_scope
      visitor.visit_program user_program, user_scope
    end
  rescue e : Exception
    puts e
    exit 1
  end
end
