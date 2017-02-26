module Charly::FileSystem

  # Common utils
  module Utils
    extend self

    # Resolves *filename* to an absolute path
    def resolve(filename, cwd)

      # Check if *filename* is already an absolute path
      if filename.starts_with? "/"
        return filename
      end

      return File.expand_path filename, cwd
    end

  end

  # Keeps track of all open files
  module FilePool
    extend self

    # All files that were opened
    Files = {} of Int32 => File

    # Opens *name* with *mode* in *encoding*
    def open(name : String, mode : String, encoding : String)
      filename = Utils.resolve name, Dir.current
      file = File.open(filename, mode, encoding: encoding)
      Files[file.fd] = file
      file.fd
    end

    # Closes *fd*
    def close(fd : Int32)
      unless check_exists fd
        raise "File descriptor #{fd} is not open"
      end

      file = Files[fd]
      file.close
    end

    # Writes *data* into *fd*
    def print(fd : Int32, data : String)
      unless check_exists fd
        raise "File descriptor #{fd} is not open"
      end

      file = Files[fd]
      file.print data
    end

    # Flushes *fd*
    def flush(fd : Int32)
      unless check_exists fd
        raise "File descriptor #{fd} is not open"
      end

      file = Files[fd]
      file.flush
    end

    # Reads a single line from the file
    def gets(fd : Int32)
      unless check_exists fd
        raise "File descriptor #{fd} is not open"
      end

      file = Files[fd]
      file.gets
    end

    # Reads *amount* bytes from *fd*
    def read_bytes(fd : Int32, amount : Int32)
      unless check_exists fd
        raise "File descriptor #{fd} is not open"
      end

      file = Files[fd]
      bytes = [] of UInt8
      amount.times do
        byte = file.read_byte

        unless byte
          break
        end

        bytes << byte
      end
      bytes
    end

    # Reads a single char from *fd*
    def read_char(fd : Int32)
      unless check_exists fd
        raise "File descriptor #{fd} is not open"
      end

      file = Files[fd]
      file.read_char
    end

    # Returns the stat for the file
    def stat(name : String)
      filename = Utils.resolve name, Dir.current
      File.stat filename
    end

    def lstat(name : String)
      filename = Utils.resolve name, Dir.current
      File.lstat filename
    end

    # Checks if *fd* exists
    def check_exists(fd : Int32)
      Files.has_key? fd
    end

  end

end
