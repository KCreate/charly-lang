const fs_open           = __internal__method("fs_open")
const fs_read           = __internal__method("fs_read")
const fs_close          = __internal__method("fs_close")
const fs_stat           = __internal__method("fs_stat")
const fs_lstat          = __internal__method("fs_lstat")
const fs_fstat          = __internal__method("fs_fstat")
const fs_gets           = __internal__method("fs_gets")
const fs_exists         = __internal__method("fs_exists")
const fs_print          = __internal__method("fs_print")
const fs_flush          = __internal__method("fs_flush")
const fs_read_bytes     = __internal__method("fs_read_bytes")
const fs_read_char      = __internal__method("fs_read_char")
const fs_write_byte     = __internal__method("fs_write_byte")
const fs_expand_path    = __internal__method("fs_expand_path")
const fs_fd_path        = __internal__method("fs_fd_path")
const fs_unlink         = __internal__method("fs_unlink")
const fs_readdir        = __internal__method("fs_readdir")
const fs_mkdir          = __internal__method("fs_mkdir")
const fs_rmdir          = __internal__method("fs_rmdir")
const fs_chmod          = __internal__method("fs_chmod")
const fs_chown          = __internal__method("fs_chown")
const fs_link           = __internal__method("fs_link")
const fs_symlink        = __internal__method("fs_symlink")
const fs_readlink       = __internal__method("fs_readlink")
const fs_rename         = __internal__method("fs_rename")
const fs_utime          = __internal__method("fs_utime")
const fs_writable       = __internal__method("fs_writable")
const fs_readable       = __internal__method("fs_readable")
const fs_truncate       = __internal__method("fs_truncate")

class File {
  static property LINE_SEPARATOR
  static property SEPARATOR

  property fd
  property filename
  property mode
  property encoding

  /**
   * Opens *name* with *mode* in *encoding*
   **/
  static func open(name, mode, encoding) {
    const fd = fs_open(name, mode, encoding)
    const filename = fs_fd_path(fd)
    const file = File(fd, filename, mode, encoding)
    file
  }

  /**
   * Returns the complete content of *name*
   **/
  static func read(name, encoding) {
    fs_read(name, encoding)
  }

  /**
   * Writes *content* to the file at *path*
   * Truncates the file if it exists already and creates it if not
   **/
  static func write(name, content) {
    const file = @open(name, "w+", "utf8")
    file.print(content)
    file.close()

    null
  }

  /**
   * Appends *content* to the file at *path*
   * Creates the file if it doesn't exist already
   **/
  static func append(name, content) {
    const file = @open(name, "a", "utf8")
    file.print(content)
    file.close()

    null
  }

  /**
   * Returns a stat object for *filename*
   **/
  static func stat(filename) {
    fs_stat(filename)
  }

  /**
   * Returns a lstat object for *filename*
   **/
  static func lstat(filename) {
    fs_lstat(filename)
  }

  /**
   * Returns true if the file at *path* exists
   * Follows symlinks
   **/
  static func exists(path) {
    @stat(path) ! null
  }

  /**
   * Returns the expanded path for *filename*, using *current* as the current working directory
   * If no current directory was passed, the current working directory of the process is used
   *
   * Returns *filename* if it could not be expanded
   **/
  static func expand_path(filename) {
    fs_expand_path(filename, arguments[1])
  }

  /**
   * Returns a new string by joining *parts* with fs.SEPARATOR
   **/
  static func join(parts) {
    unless typeof parts == "Array" {
      throw Exception("Expected parts to be an array, got " + typeof parts)
    }

    parts.join(@SEPARATOR)
  }

  /**
   * Unlinks a name from the filesystem and possibly the file it refers to
   **/
  static func unlink(path) {
    fs_unlink(path)
  }

  /**
   * Alias for fs.unlink
   **/
  static func delete(path) {
    if @is_directory(path) {
      @rmdir(path)
    } else {
      @unlink(path)
    }
  }

  /**
   * Returns the size of the file at *path* in bytes
   **/
  static func size(path) {
    const stat = @stat(path)
    unless stat { throw Exception("Failed to stat " + path) }
    stat.size
  }

  /**
   * Returns true if the file at *path* is empty
   **/
  static func empty(path) {
    @size(path) == 0
  }

  /**
   * Deletes the directory at *path*
   **/
  static func rmdir(path) {
    fs_rmdir(path)
  }

  /**
   * Returns an array of filenames inside a given directory
   **/
  static func readdir(path) {
    fs_readdir(path)
  }

  /**
   * Creates a directory at *path*
   **/
  static func mkdir(path) {
    fs_mkdir(path)
  }

  /**
   * Returns the last component of a path
   **/
  static func basename(path) {
    path = path.split(@SEPARATOR)
    path.last()
  }

  /**
   * Returns all components of a path except the last one
   **/
  static func dirname(path) {
    path = path.split(@SEPARATOR)
    path.pop()
    path.join(@SEPARATOR)
  }

  /**
   * Returns *path*'s extension, or an empty string if it has no extension
   **/
  static func extname(path) {
    const dot_index = path.rindex(".", -1)
    const path_length = path.length()

    if dot_index ! -1 && dot_index ! path_length - 1 && path[dot_index - 1] ! @SEPARATOR {
      path.substring(dot_index, path_length - dot_index)
    } else {
      ""
    }
  }

  /**
   * Changes the mode of the file at *path*
   **/
  static func chmod(path, mode) {
    fs_chmod(path, mode)
  }

  /**
   * Changes the user and group id of the file at *path*
   **/
  static func chown(path, uid, gid) {
    fs_chown(path, uid, gid)
  }

  /**
   * Creates a new link at *new* pointing to the file at *old*
   **/
  static func link(old, new) {
    fs_link(old, new)
  }

  /**
   * Creates a new symbolic link at *new* pointing to *old*
   **/
  static func symlink(old, new) {
    fs_symlink(old, new)
  }

  /**
   * Returns the absolute path, the link *path* points to
   **/
  static func readlink(path) {
    fs_readlink(path)
  }

  /**
   * Renames the file at *old* to *new*
   **/
  static func rename(old, new) {
    fs_rename(old, new)
  }

  /**
   * Returns true if *path* is a directory
   **/
  static func is_directory(path) {
    !!(@lstat(path).directory)
  }

  /**
   * Returns true if *path* is a file
   **/
  static func is_file(path) {
    !!(@lstat(path).file)
  }

  /**
   * Returns true if *path* is a symlink
   **/
  static func is_link(path) {
    !!(@lstat(path).symlink)
  }

  /**
   * Calls the callback with each line and index of the file at *path*
   **/
  static func each_line(path, encoding, callback) {
    const file = @open(path, "r", encoding)
    file.each_line(callback)
    file.close()
  }

  /**
   * Sets the access and modification timestamps of the file at path
   **/
  static func utime(path, atime, mtime) {
    fs_utime(path, atime, mtime)
  }

  /**
   * Returns true if the file at *path* is writable
   * Otherwise returns false
   **/
  static func writable(path) {
    fs_writable(path)
  }

  /**
   * Returns true if the file at *path* is readable
   * Otherwise returns false
   **/
  static func readable(path) {
    fs_readable(path)
  }

  func constructor(fd, filename, mode, encoding) {
    @fd = fd
    @filename = filename
    @mode = mode
    @encoding = encoding
  }

  /**
   * Read a line from the underlying file descriptor
   *
   * Returns null if nothing could be read
   **/
  func gets() {
    @check_open()
    fs_gets(@fd)
  }

  /**
   * Reads *amount* bytes from the underlying file descriptor
   * Returns an array of numbers
   *
   * If not enough bytes could be read, the array will be shorter
   **/
  func read_bytes(amount) {
    @check_open()
    fs_read_bytes(@fd, amount)
  }

  /**
   * Reads a single char from the underlying file descriptor
   *
   * Returns null if no char could be read
   **/
  func read_char() {
    @check_open()
    fs_read_char(@fd)
  }

  /**
   * Writes *data* into the underlying file descriptor
   **/
  func print(data) {
    @check_open()
    fs_print(@fd, data.to_s())
    fs_flush(@fd)

    self
  }

  /**
   * Writes *data* into the underlying file descriptor
   * If data doesn't end with a newline, a newline is appended
   **/
  func puts(data) {
    @check_open()
    fs_print(@fd, data.to_s())

    unless data.last() == "\n" {
      fs_print(@fd, "\n")
    }

    fs_flush(@fd)

    self
  }

  /**
   * Calls the callback with each line in this file
   **/
  func each_line(callback) {
    @check_open()

    let tmp
    let i = 0
    while tmp = fs_gets(@fd) {
      callback(tmp, i)
      i += 1
    }

    self
  }

  /**
   * Writes *byte* into the underlying file descriptor
   **/
  func write_byte(byte) {
    @check_open()
    fs_write_byte(@fd, byte.to_n())

    self
  }

  /**
   * Writes *bytes* into the underlying file descriptor
   **/
  func write_bytes(bytes) {
    @check_open()

    unless typeof bytes == "Array" {
      throw Exception("Expected bytes to be an array, got " + typeof bytes)
    }

    bytes.each(->(byte) {
      fs_write_byte(@fd, byte.to_n())
    })

    fs_flush(@fd)

    self
  }

  /**
   * Flushes all buffered data
   **/
  func flush() {
    @check_open()
    fs_flush(@fd)

    self
  }

  /**
   * Closes the underlying file descriptor
   **/
  func close() {
    @check_open()
    fs_close(@fd)

    self
  }

  /**
   * Tries to open this file
   **/
  func open() {
    const file = File.open(@filename, @mode, @encoding)

    @fd = file.fd
    @filename = file.filename
    @mode = file.mode
    @encoding = file.encoding

    self
  }

  /**
   * Checks if the underlying file descriptor is still open
   **/
  func check_open() {
    const exists = fs_exists(@fd)

    unless exists {
      throw Exception("Can't perform action on closed file descriptor " + @fd)
    }

    exists
  }

  /**
   * Returns the stat object for the underlying file descriptor
   **/
  func stat() {
    fs_fstat(@fd)
  }

  /**
   * Returns the size of the currently open file
   **/
  func size() {
    @stat().size || 0
  }

  /**
   * Trunactes the underlying file to *size*
   **/
  func truncate(size) {
    fs_truncate(@fd, size)
  }

}

File.LINE_SEPARATOR = "\n"
File.SEPARATOR = "/"

export = File
