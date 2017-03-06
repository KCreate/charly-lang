const fs = require("fs")

const Type = {
  const Dir = 0
  const File = 1
}

class Node {
  property path
  property dir
  property children

  func constructor(path, dir) {
    @path = fs.expand_path(path)
    @dir = dir
    @children = []

    if dir && fs.is_directory(path) {
      @load_children()
    }
  }

  func load_children() {
    const entries = fs.readdir(@path)

    entries.each(->(entry) {

      // skip unwanted directories
      if entry == "." || entry == ".." {
        return
      }

      entry = fs.expand_path(entry, @path)
      @children.push(Node(entry, fs.is_directory(entry)))
    })
  }

  func print(depth) {
    write("  " * depth)
    print("- " + fs.basename(@path))

    @children.each(->$0.print(depth + 1))
  }
}

loop {
  Node(gets("> ", true) || ".", true).print(0)
  print("")
}
