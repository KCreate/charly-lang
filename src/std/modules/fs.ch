const fs_open           = __internal__method("fs_open")
const fs_read           = __internal__method("fs_read")
const fs_close          = __internal__method("fs_close")
const fs_stat           = __internal__method("fs_stat")
const fs_lstat          = __internal__method("fs_lstat")
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
const fs_type           = __internal__method("fs_type")
const fs_mkdir          = __internal__method("fs_mkdir")
const fs_rmdir          = __internal__method("fs_rmdir")

class IOError extends Exception {}

class File {
  static property LINE_SEPARATOR

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
   * Returns the expanded path for *filename*, using *current* as the current working directory
   * If no current directory was passed, the current working directory of the process is used
   *
   * Returns *filename* if it could not be expanded
   **/
  static func expand_path(filename) {
    fs_expand_path(filename, arguments[1])
  }

  /**
   * Unlinks a name from the filesystem and possibly the file it refers to
   **/
  static func unlink(filename) {
    fs_unlink(filename)
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
   * Returns the type of the file at path
   * See `fs.TYPES` for definitions
   **/
  static func type(path) {
    fs_type(path)
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
    path = path.split(@DIRECTORY_SEPARATOR)
    path.last()
  }

  /**
   * Returns all components of a path except the last one
   **/
  static func dirname(path) {
    path = path.split(@DIRECTORY_SEPARATOR)
    path.pop()
    path.join(@DIRECTORY_SEPARATOR)
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
      throw IOError("Expected bytes to be an array, got " + typeof bytes)
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
      throw IOError("Can't perform action on closed file descriptor " + @fd)
    }

    exists
  }

}

File.LINE_SEPARATOR = "\n"
File.DIRECTORY_SEPARATOR = "/"
File.TYPES = {
  const UNKNOWN = -1
  const FILE = 0
  const DIR = 1
  const LINK = 2
}

export = File
