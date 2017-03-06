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

  charly_api "fs_read", path : TString, encoding : TString do
    path = Utils.resolve path.value, Dir.current
    encoding = encoding.value

    begin
      return TString.new File.read(path, encoding: encoding)
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not read #{path}")
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

  charly_api "fs_stat", path : TString do
    path = Utils.resolve path.value, Dir.current

    begin
      return Utils.stat_to_object File.stat path
    rescue e
      return TNull.new
    end
  end

  charly_api "fs_lstat", path : TString do
    path = Utils.resolve path.value, Dir.current

    begin
      return Utils.stat_to_object File.lstat path
    rescue e
      return TNull.new
    end
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

  charly_api "fs_chown", path : TString, uid : TNumeric, gid : TNumeric do
    path = Utils.resolve path.value, Dir.current
    uid, gid = uid.value.to_i32, gid.value.to_i32

    begin
      File.chown path, uid, gid
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not chown #{path}")
    end

    TNull.new
  end

  charly_api "fs_link", old : TString, new : TString do
    old = Utils.resolve old.value, Dir.current
    new = Utils.resolve new.value, Dir.current

    begin
      ret = LibC.link(old.check_no_null_byte, new.check_no_null_byte)
      raise Errno.new("Error creating link from #{old} to #{new}") if ret != 0
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not link #{new} to #{old}")
    end

    TNull.new
  end

  charly_api "fs_symlink", old : TString, new : TString do
    old = old.value
    new = Utils.resolve new.value, Dir.current

    begin
      File.symlink old, new
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not symlink #{new} to #{old}")
    end

    TNull.new
  end

  charly_api "fs_readlink", path : TString do
    path = Utils.resolve path.value, Dir.current

    unless File.symlink? path
      raise RunTimeError.new(call, context, "#{path} is not a symlink")
    end

    begin
      return TString.new File.real_path path
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not read link at #{path}")
    end
  end

  charly_api "fs_rename", old : TString, new : TString do
    old = Utils.resolve old.value, Dir.current
    new = Utils.resolve new.value, Dir.current

    begin
      File.rename old, new
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not rename #{old} to #{new}")
    end

    TNull.new
  end

  charly_api "fs_utime", path : TString, atime : TNumeric, mtime : TNumeric do
    path = Utils.resolve path.value, Dir.current
    atime, mtime = atime.value.to_i64, mtime.value.to_i64

    atime = Time.epoch atime
    mtime = Time.epoch mtime

    begin
      File.utime(atime, mtime, path)
    rescue e
      raise RunTimeError.new(call, context, e.message || "Could not utime #{path}")
    end

    TNull.new
  end

  charly_api "fs_writable", path : TString do
    path = Utils.resolve path.value, Dir.current
    TBoolean.new File.writable? path
  end

  charly_api "fs_readable", path : TString do
    path = Utils.resolve path.value, Dir.current
    TBoolean.new File.readable? path
  end
end
