require "../**"
require "./fs/filepool.cr"

module Charly::Internals
  include FileSystem

  # Opens *name* and returns the file descriptor
  charly_api "fs_open", name : TString, mode : TString, encoding : TString do
    name, mode, encoding = name.value, mode.value, encoding.value

    begin
      fd = FilePool.open name, mode, encoding
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not open #{name}")
    end

    TNumeric.new fd
  end

  charly_api "fs_read", name : TString, encoding : TString do
    name, encoding = name.value, encoding.value

    begin
      return TString.new FilePool.read name, encoding
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not read #{name}")
    end
  end

  charly_api "fs_close", fd : TNumeric do
    fd = fd.value.to_i32

    begin
      FilePool.close fd
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not close #{fd}")
    end

    TNull.new
  end

  charly_api "fs_expand_path", filename : TString, current : BaseType do
    filename = filename.value

    if current.is_a? TString
      return TString.new Utils.resolve filename, current.value
    end

    TString.new Utils.resolve filename, Dir.current
  end

  charly_api "fs_fd_path", fd : TNumeric do
    fd = fd.value.to_i32

    begin
      return TString.new FilePool.fd_path fd
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not get filename of #{fd}")
    end
  end

  charly_api "fs_unlink", filename : TString do
    filename = Utils.resolve filename.value, Dir.current

    begin
      File.delete filename
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not unlink #{filename}")
    end

    TNull.new
  end

  charly_api "fs_rmdir", path : TString do
    path = Utils.resolve path.value, Dir.current

    begin
      Dir.rmdir path
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not delete #{path}")
    end

    TNull.new
  end

  charly_api "fs_readdir", path : TString do
    path = Utils.resolve path.value, Dir.current

    entries : Array(String)

    begin
      entries = Dir.entries path
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not readdir #{path}")
    end

    ch_entries = [] of BaseType
    entries.each do |filename|
      ch_entries << TString.new filename
    end

    TArray.new ch_entries
  end

  charly_api "fs_type", path : TString do
    path = Utils.resolve path.value, Dir.current

    begin

      # The check for symlinks is performed first, because File.file? returns
      # true for symlinked files too
      return TNumeric.new 2 if File.symlink? path
      return TNumeric.new 0 if File.file? path
      return TNumeric.new 1 if File.directory? path
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not get type for #{path}")
    end

    TNumeric.new -1
  end

  charly_api "fs_mkdir", path : TString do
    path = Utils.resolve path.value, Dir.current

    begin
      Dir.mkdir_p path
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not create dir at #{path}")
    end

    TNull.new
  end

  charly_api "fs_gets", fd : TNumeric do
    fd = fd.value.to_i32

    begin
      line = FilePool.gets fd

      if line
        return TString.new line
      end

      return TNull.new
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not read from #{fd}")
    end
  end

  charly_api "fs_print", fd : TNumeric, data : TString do
    fd, data = fd.value.to_i32, data.value

    begin
      FilePool.print fd, data
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not print to #{fd}")
    end

    TNull.new
  end

  charly_api "fs_write_byte", fd : TNumeric, byte : TNumeric do
    fd, byte = fd.value.to_i32, byte.value

    begin
      FilePool.write_byte fd, byte.to_u8
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not write to #{fd}")
    end

    TNull.new
  end

  charly_api "fs_flush", fd : TNumeric do
    fd = fd.value.to_i32

    begin
      FilePool.flush fd
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not flush #{fd}")
    end

    TNull.new
  end

  charly_api "fs_read_bytes", fd : TNumeric, amount : TNumeric do
    fd, amount = fd.value.to_i32, amount.value.to_i32

    begin
      bytes = FilePool.read_bytes fd, amount
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not read from #{fd}")
    end

    ch_bytes = TArray.new [] of BaseType
    bytes.each do |byte|
      ch_bytes.value << TNumeric.new byte
    end
    ch_bytes
  end

  charly_api "fs_read_char", fd : TNumeric do
    fd = fd.value.to_i32

    begin
      char = FilePool.read_char fd
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not read from #{fd}")
    end

    if char.is_a? Nil
      return TNull.new
    end

    TString.new char.to_s
  end

  charly_api "fs_exists", fd : TNumeric do
    fd = fd.value.to_i32
    TBoolean.new FilePool::Files.has_key? fd
  end

  charly_api "fs_stat", name : TString do
    stat = FilePool.stat name.value
    TObject.new do |obj|
      obj.init("dev",     TNumeric.new(stat.dev), true)
      obj.init("mode",    TNumeric.new(stat.mode), true)
      obj.init("nlink",   TNumeric.new(stat.nlink), true)
      obj.init("uid",     TNumeric.new(stat.uid), true)
      obj.init("gid",     TNumeric.new(stat.gid), true)
      obj.init("rdev",    TNumeric.new(stat.rdev), true)
      obj.init("blksize", TNumeric.new(stat.blksize), true)
      obj.init("ino",     TNumeric.new(stat.ino), true)
      obj.init("size",    TNumeric.new(stat.size), true)
      obj.init("blocks",  TNumeric.new(stat.blocks), true)
      obj.init("atime",   TNumeric.new(stat.atime.epoch), true)
      obj.init("mtime",   TNumeric.new(stat.mtime.epoch), true)
      obj.init("ctime",   TNumeric.new(stat.ctime.epoch), true)
    end
  end

  charly_api "fs_lstat", name : TString do
    stat = FilePool.lstat name.value
    TObject.new do |obj|
      obj.init("dev",     TNumeric.new(stat.dev), true)
      obj.init("mode",    TNumeric.new(stat.mode), true)
      obj.init("nlink",   TNumeric.new(stat.nlink), true)
      obj.init("uid",     TNumeric.new(stat.uid), true)
      obj.init("gid",     TNumeric.new(stat.gid), true)
      obj.init("rdev",    TNumeric.new(stat.rdev), true)
      obj.init("blksize", TNumeric.new(stat.blksize), true)
      obj.init("ino",     TNumeric.new(stat.ino), true)
      obj.init("size",    TNumeric.new(stat.size), true)
      obj.init("blocks",  TNumeric.new(stat.blocks), true)
      obj.init("atime",   TNumeric.new(stat.atime.epoch), true)
      obj.init("mtime",   TNumeric.new(stat.mtime.epoch), true)
      obj.init("ctime",   TNumeric.new(stat.ctime.epoch), true)
  end

  charly_api "fs_chmod", path : TString, mode : TNumeric do
    path = Utils.resolve path.value, Dir.current
    mode = mode.value.to_i32

    begin
      File.chmod path, mode
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not chmod #{path}")
    end

    TNull.new
  end
end
