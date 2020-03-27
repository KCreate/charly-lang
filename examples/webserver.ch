const http = require("net")
const fs = require("fs")
const server = http.create_server("localhost", 8080)

server.on("request", ->(req, res) {
  res.set_header("Content-type", "text/html")
  res.body = fs.read("examples/data/index.html", "utf8")

  res.body = res.body.split("{{time}}").join(io.time_ms())
})

server.on("listen", ->{
  print("listening on localhost:8080")
})

server.on("close", ->{
  print("closing server")
})

server.listen()
