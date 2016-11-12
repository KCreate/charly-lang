require "./**"

module Charly::Require
  extend self

  class FileNotFoundException < BaseException
    property path : String

    def initialize(@path, @message)
    end
  end

  # A list of core modules the interpreter provides
  CORE_MODULES = [
    "math",
    "io",
    "unit-test"
  ] of String

  # Loads *filename* and returns the value of the export variable
  def load(filename, context, cwd)
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
end
