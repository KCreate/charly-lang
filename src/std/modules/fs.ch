const fs_open = __internal__method("fs_open")
const fs_close = __internal__method("fs_close")
const fs_stat = __internal__method("fs_stat")
const fs_lstat = __internal__method("fs_lstat")

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
   * Closes the underlying file descriptor
   **/
  func close() {
    fs_close(@fd)
  }

}

export = File
