require "./**"

module Charly::Require
  extend self

  # Exception thrown when a file could not be loaded
  class FileNotFoundException < BaseException
    property path : String

    def initialize(@path, @message)
    end
  end

  # Cache previous require calls
  @@cache = {} of String => BaseType

  # A list of core modules the interpreter provides
  CORE_MODULES = [] of String

  # Loads *filename* and returns the value of the export variable
  def load(filename, cwd)
    path = resolve(filename, cwd)

    # Check the cache for an entry
    if @@cache.has_key? path
      return @@cache[path]
    end

    # Try to load as a file
    could_include_as_file = load_as_file(path)

    if could_include_as_file
      @@cache[path] = could_include_as_file
      return could_include_as_file
    end

    raise FileNotFoundException.new(filename, "Can't load file (#{filename})")
  end

  # Resolves *filename* to a absolute path
  #
  # If *filename* is a core-module, the path to that module will be returned
  # If the path starts with "./" or '../' it gets resolved relative to the current directory
  # If the path starts with "/" it's treated as an already absolute path
  def resolve(filename, cwd)

    # Check if it's a core-module
    if CORE_MODULES.includes? filename
      return File.expand_path("/src/std/modules/#{filename}.charly", ENV["CHARLYDIR"])
    end

    # Relative paths
    if filename.starts_with?("./") || filename.starts_with?("../")
      return File.expand_path(filename, cwd)
    end

    # Absolute paths
    if filename.starts_with?("/")
      return filename
    end

    raise FileNotFoundException.new(filename, "Can't load file (#{filename})")
  end

  # Loads *path*
  private def load_as_file(path)

    # Check if the path is accessable
    if File.exists?(path) && File.readable?(path)

      # The scope in which the included file will run
      include_scope = Scope.new
      include_scope.write("export", TNull.new, Flag::INIT)

      # Load the included file
      interpreter = Interpreter.new include_scope, true
      program = Parser.create(File.open(path), path)
      return interpreter.exec_program program
    end

    return TNull.new
  end
end
