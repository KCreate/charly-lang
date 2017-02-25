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

    # Reads a single line from the file
    def gets(fd : Int32)
      unless check_exists fd
        raise "File descriptor #{fd} is not open"
      end

      file = Files[fd]
      file.gets
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
