const Server = require("./server.ch")
const Request = Server.Request
const Response = Server.Response

class HTTP {
  static func create_server(address, port) {
    Server(address, port)
  }
}

export = HTTP
export.Server = Server
export.Request = Request
export.Response = Response
