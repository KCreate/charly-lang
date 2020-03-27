const net_response_close = __internal__method("net_response_close")

class Response {
  property response_id
  property status_code
  property body
  property headers

  func constructor(data) {
    @response_id = data.__response_id
    @status_code = data.status_code
    @body = data.body
    @headers = data.headers
  }

  /**
   * Closes the response, writing headers and body if not done yet
   **/
  func close() {
    net_response_close(@response_id)
    self
  }

  func set_header(name, value) {
    const values = @headers[name]

    if typeof values == "Array" {
      values << value.to_s()
    } else {
      @headers[name] = [value.to_s()]
    }

    self
  }
}

export = Response
