const fs_open = __internal__method("fs_open")
const fs_close = __internal__method("fs_close")
const fs_gets = __internal__method("fs_gets")
const fs_rewind = __internal__method("fs_rewind")
const fs_read = __internal__method("fs_read")

/**
 * File
 *
 * Contains bindings to the filesystem that allow to read and write from files, create new ones
 * and access all the methods regarding the filesystem
 *
 **/
class File {
  property fd
  property filename

  /**
   * Opens a file
   *
   * Returns a File object
   **/
  static func open(filename) {
    const mode = arguments[1] || "r"
    const encoding = arguments[2] || "utf8"
    const callback = arguments[3]

    const fd = fs_open(filename, mode, encoding)
    const file = File(fd, filename)

    if typeof callback == "Function" {
      const result = callback(file)
      file.close()
      return result
    }

    return file
  }

  /**
   * Returns the full content of a file
   *
   * Returns a string
   **/
  static func read(filename) {
    const mode = arguments[1] || "r"
    const encoding = arguments[2] || "utf8"
    const callback = arguments[3]

    const fd = fs_open(filename, mode, encoding)
    const file = File(fd, filename)

    const lines = []
    const content = file.each_line(->(line) lines.push(line)).join("\n")

    if typeof callback == "Function" {
      const result = callback(content)
      file.close()
      return result
    }

    return content
  }

  /**
   * Creates a new File object for a given file descriptor and filename
   **/
  func constructor(fd, filename) {
    @fd = fd
    @filename = filename
  }

  /**
   * Closes the current file
   **/
  func close() {
    fs_close(@fd)
  }

  /**
   * Reads a line from the current file handle
   **/
  func gets() {
    fs_gets(@fd)
  }

  /**
   * Rewind the internal file pointer to the beginning
   **/
  func rewind() {
    fs_rewind(@fd)
  }

  /**
   * Read *amount* of bytes from this file handle
   **/
  func read(amount) {
    fs_read(@fd, amount)
  }

  /**
   * Calls the callback with each line
   **/
  func each_line(callback) {
    let tmp
    while tmp = @gets() {
      callback(tmp)
    }
  }

}

export = File
