module Slack::Executable
  def before_execute
    @before_execute ||= [] of (Request ->)
  end

  def before_execute(&callback : Request ->)
    before_execute << callback
  end

  def after_execute
    @after_execute ||= [] of ((Request, HTTP::Client::Response?) ->)
  end

  def after_execute(&callback : (Request, HTTP::Client::Response?) ->)
    after_execute << callback
  end

  ######################################################################
  ### build HTTP::Request

  def request(method : Api::Method, params = nil, headers = nil, body = nil)
    if params && token?
      params = params.merge({"token" => token})
    end
    Slack::Request.new(uri, method.path, "GET", params: params, headers: headers, body: body)
  end

  ######################################################################
  ### HTTP methods (low level)
    
  def execute(req : Request) : Response
    response : HTTP::Client::Response? = nil

    # calculate runtime values before calling `before_execute`
    before_execute.each &.call(req)

    if dryrun
      raise Dryrun.new(req)
    end

    http_client  = new_http_client(req.uri)
    http_request = new_http_request(req)

    response = http_client.exec(http_request)
    return Response.new(response, req)

  ensure
    if res = response
      logger.debug "HTTP response (status %s)" % res.status_code
      logger.debug "HTTP response: %s" % res.headers.to_h
    end

    after_execute.each(&.call(req, response))
  end

  protected def new_http_client(uri : URI) : HTTP::Client
    http = HTTP::Client.new(uri)
    http.dns_timeout     = dns_timeout
    http.connect_timeout = connect_timeout
    http.read_timeout    = read_timeout
    return http
  end

  protected def new_http_request(req : Request) : HTTP::Request
    req.http_request
  end
end
