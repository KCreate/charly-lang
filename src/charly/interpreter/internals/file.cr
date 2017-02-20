require "../**"

module Charly::Internals

  module Utils
    extend self

    # Resolves *filename* to a absolute path
    #
    # If the path starts with "./" or '../' it gets resolved relative to the current directory
    # If the path starts with "/" it's treated as an already absolute path
    def resolve(filename, cwd)

      # Absolute paths
      if filename.starts_with?("/")
        return filename
      end

      return File.expand_path(filename, cwd)
    end
  end

  class FilePool
    Files = {} of Int32 => File

    def self.get(fd)
      Files[fd.to_i32]?
    end
  end

  charly_api "fs_open", filename : TString, mode : TString, encoding : TString  do

    # Extract value properties
    filename = filename.value
    mode = mode.value
    encoding = encoding.value

    # Get the correct relative path
    filename = Utils.resolve filename, Dir.current

    file : File
    begin
      file = File.open(filename, mode, encoding: encoding)
    rescue e
      raise RunTimeError.new(call, e.message || "Can't open #{filename}")
    end

    fd = file.fd
    FilePool::Files[fd] = file
    return TNumeric.new fd
  end

  charly_api "fs_close", fd : TNumeric do
    file = FilePool.get fd.value

    unless file
      raise RunTimeError.new(call, "Can't find file handle #{fd}")
    end

    begin
      file.close
    rescue e
      raise RunTimeError.new(call, e.message || "Can't close file.filename")
    end

    return TNull.new
  end

  charly_api "fs_gets", fd : TNumeric do
    file = FilePool.get fd.value

    unless file
      raise RunTimeError.new(call, "Can't find file handle #{fd}")
    end

    line = file.gets

    if line
      return TString.new line
    end

    return TNull.new
  end

  charly_api "fs_rewind", fd : TNumeric do
    file = FilePool.get fd.value

    unless file
      raise RunTimeError.new(call, "Can't find file handle #{fd}")
    end

    file.rewind
    return TNull.new
  end

  charly_api "fs_read", fd : TNumeric, amount : TNumeric do
    file = FilePool.get fd.value
    amount = amount.value.to_i32

    unless file
      raise RunTimeError.new(call, "Can't find file handle #{fd}")
    end

    amount = 0 if amount < 0

    input = Bytes.new amount
    file.read input

    return TString.new String.new input
  end
end
