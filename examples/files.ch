const fs = require("fs")
const file = fs.open(ARGV[0], "r", "utf8")

file.each_line(->(line) {
  line.each(->(char) {
    write(char)

    io.sleep(ARGV[1].to_n())
  })

  write("\n")
})

file.close()
