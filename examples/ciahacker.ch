class Progress {
  property pos
  property max
  property width

  func constructor(width) {
    @pos = 0
    @max = 100
    @width = width
  }

  func tick() {
    @pos += 1
    @print()
  }

  func print() {
    @reset()
    let amount = @pos / @max * @width
    write("#" * amount, "\r")
  }

  func reset() {
    write(" " * @width, "\r")
  }
}

const progressView = Progress(30)

const messages = [
  "Starting up hacking software",
  "Warming up hacking nodes",
  "Connecting to CIA server",
  "Downloading information",
  "Uploading information to private servers",
  "Deleting traces"
]

let i = 0
let mi = 0

while (mi < messages.length()) {
  progressView.reset()
  print(messages[mi])
  i = 0
  progressView.pos = 0
  while (i < 100) {
    progressView.tick()
    sleep(200 / (i + 1 + mi))
    i += 1
  }
  mi += 1
}
