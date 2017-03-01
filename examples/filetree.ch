const fs = require("fs")

class Node {
  property path
  property type
  property children

  func constructor(path, type) {
    @path = fs.expand_path(path)
    @type = type
    @children = []

    if type == fs.TYPES.DIR {
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
      @children.push(Node(entry, fs.type(entry)))
    })
  }

  func print(depth) {
    write("  " * depth)
    print("- " + fs.basename(@path))

    @children.each(->$0.print(depth + 1))
  }
}

loop {
  Node(gets("> ", true) || ".", fs.TYPES.DIR).print(0)
  print("")
}
