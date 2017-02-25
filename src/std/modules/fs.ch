const fs_open = __internal__method("fs_open")
const fs_close = __internal__method("fs_close")
const fs_stat = __internal__method("fs_stat")
const fs_lstat = __internal__method("fs_lstat")
const fs_gets = __internal__method("fs_gets")
const fs_exists = __internal__method("fs_exists")

class File {
  property fd
  property filename
  property mode
  property encoding

  /**
   * Opens *name* with *mode* in *encoding*
   **/
  static func open(name, mode, encoding) {
    const fd = fs_open(name, mode, encoding)
    const file = File(fd, name, mode, encoding)
    return file
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
   * Closes the underlying file descriptor
   **/
  func close() {
    @check_open()
    fs_close(@fd)
  }

  /**
   * Checks if the underlying file descriptor is still open
   **/
  func check_open() {
    const exists = fs_exists(@fd)

    unless exists {
      throw Exception("Can't perform action on closed file descriptor " + @fd)
    }
  }

}

export = File
