require "./**"

module Charly::Require
  extend self

  # Exception thrown when a file could not be loaded
  class FileNotFoundException < BaseException
    property path : String

    def initialize(@path, @message)
    end
  end

  # A list of core modules the interpreter provides
  CORE_MODULES = [
    "unit-test",
    "math",
    "charly",
  ] of String

  # Loads *filename* and returns the value of the export variable
  def load(filename, cwd, visitor, context)
    path = resolve(filename, cwd)

    # Check the cache for an entry
    if context.cached_files.has_key? path
      return context.cached_files[path]
    end

    # Try to load as a file
    could_include_as_file = load_as_file(path, visitor, context)

    if could_include_as_file
      context.cached_files[path] = could_include_as_file
      return could_include_as_file
    end

    raise FileNotFoundException.new(filename, "Can't load file (#{filename})")
  end

  # Loads *path*
  private def load_as_file(path, visitor, context)
    # Check if the path is accessable
    if File.exists?(path) && File.readable?(path)
      # The scope in which the included file will run
      scope = Scope.new(visitor.prelude)

      # Parse the input file
      program = Parser.create(File.open(path), path)
      visitor.visit_program(program, scope, context)
      return scope.get("export")
    end

    return nil
  end

  # Resolves *filename* to a absolute path
  #
  # If *filename* is a core-module, the path to that module will be returned
  # If the path starts with "./" or '../' it gets resolved relative to the current directory
  # If the path starts with "/" it's treated as an already absolute path
  def resolve(filename, cwd)

    # Check if it's a core-module
    if CORE_MODULES.includes? filename
      return File.join(ENV["CHARLYDIR"], "/src/std/modules/#{filename}.ch")
    end

    # Absolute paths
    if filename.starts_with?("/")
      return filename
    end

    return File.expand_path(filename, cwd)
  end
end
