class Request {
  property body
  property content_length
  property host
  property ignore_body
  property keep_alive
  property method
  property path
  property query
  property resource
  property version
  property query_params
  property headers
  property cookies

  func constructor(data) {
    @body = data.body
    @content_length = data.content_length
    @host = data.host
    @ignore_body = data.ignore_body
    @keep_alive = data.keep_alive
    @method = data.method
    @path = data.path
    @query = data.query
    @resource = data.resource
    @version = data.version
    @query_params = data.query_params
    @headers = data.headers
    @cookies = data.cookies
  }
}

export = Request
