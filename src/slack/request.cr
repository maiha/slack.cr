class Slack::Request
  var uri     : URI
  var method  : String = "GET"
  var params  : Hash(String, String)
  var headers : HTTP::Headers = HTTP::Headers.new
  var body    : String = ""

  var http_request : HTTP::Request
  var computed_uri : URI

  def initialize(uri : URI, path : String, @method = nil, @params = nil, @headers = nil, @body = nil)
    @uri = uri.dup.tap{|v| v.path = path}
    #@headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded"}
    @http_request = build_http_request
    @computed_uri = uri.dup.tap{|v| v.path = http_request.resource}
  end

  def url : String
    uri.to_s
  end

  private def build_http_request : HTTP::Request
    case method
    when "GET"
      path = uri.path
      path += "?#{to_query_string(params)}" if params.any?
      req = HTTP::Request.new(method, path, build_headers)
      return req
    when "POST"
      path = uri.path
      body = HTTP::Params.encode(params)
      req = HTTP::Request.new(method, path, build_headers, body)
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      return req
    else
      raise "#{self.class} doesn't support method: #{@method}"
    end
  end    

  private def build_headers : HTTP::Headers
    HTTP::Headers{
      "Content-Type"  => "application/json",
      "Accept"        => "application/json",
    }
  end

  private def to_query_string(hash : Hash)
    HTTP::Params.build do |form_builder|
      hash.each do |key, value|
        form_builder.add(key, value)
      end
    end
  end
end
