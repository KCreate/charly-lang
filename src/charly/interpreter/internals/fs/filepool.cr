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

    # Converts a File::Stat object to a charly object
    def stat_to_object(stat : File::Stat)
      TObject.new do |obj|
        obj.init "atime",     TNumeric.new stat.atime.epoch
        obj.init "mtime",     TNumeric.new stat.mtime.epoch
        obj.init "ctime",     TNumeric.new stat.ctime.epoch

        obj.init "blockdev",  TBoolean.new stat.blockdev?
        obj.init "directory", TBoolean.new stat.directory?
        obj.init "file",      TBoolean.new stat.file?
        obj.init "pipe",      TBoolean.new stat.pipe?
        obj.init "setgid",    TBoolean.new stat.setgid?
        obj.init "setuid",    TBoolean.new stat.setuid?
        obj.init "socket",    TBoolean.new stat.socket?
        obj.init "sticky",    TBoolean.new stat.sticky?
        obj.init "symlink",   TBoolean.new stat.symlink?
        obj.init "chardev",   TBoolean.new stat.chardev?

        obj.init "blksize",   TNumeric.new stat.blksize
        obj.init "blocks",    TNumeric.new stat.blocks
        obj.init "dev",       TNumeric.new stat.dev
        obj.init "gid",       TNumeric.new stat.gid
        obj.init "ino",       TNumeric.new stat.ino
        obj.init "mode",      TNumeric.new stat.mode
        obj.init "nlink",     TNumeric.new stat.nlink
        obj.init "perm",      TNumeric.new stat.perm
        obj.init "rdev",      TNumeric.new stat.rdev
        obj.init "size",      TNumeric.new stat.size
        obj.init "uid",       TNumeric.new stat.uid
      end
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
      check_open fd
      file = Files[fd]
      file.close
    end

    # Writes *data* into *fd*
    def print(fd : Int32, data : String)
      check_open fd
      file = Files[fd]
      file.print data
    end

    # Writes *byte* into *fd*
    def write_byte(fd : Int32, byte : UInt8)
      check_open fd
      file = Files[fd]
      file.write_byte byte
    end

    # Flushes *fd*
    def flush(fd : Int32)
      check_open fd
      file = Files[fd]
      file.flush
    end

    # Reads a single line from the file
    def gets(fd : Int32)
      check_open fd
      file = Files[fd]
      file.gets
    end

    # Reads *amount* bytes from *fd*
    def read_bytes(fd : Int32, amount : Int32)
      check_open fd
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
      check_open fd
      file = Files[fd]
      file.read_char
    end

    # Checks if *fd* exists
    def check_open(fd : Int32)
      exists = open? fd

      unless exists
        raise "File descriptor #{fd} is not registered"
      end

      exists
    end

    def open?(fd : Int32)
      Files.has_key? fd
    end

    # Returns the path of a file descriptor
    def fd_path(fd : Int32)
      check_open fd
      file = Files[fd]
      file.path
    end

    # Returns the stat object for a file descriptor
    def fstat(fd : Int32)
      check_open fd
      file = Files[fd]
      Utils.stat_to_object file.stat
    end

    # Truncates *fd* to *size*
    def truncate(fd : Int32, size : Int32)
      check_open fd
      file = Files[fd]
      file.truncate size
    end

  end

end
