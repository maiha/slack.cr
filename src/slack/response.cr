class Slack::Response
  class Meta
    # {"ok":false,"error":"missing_scope",...}
    JSON.mapping(
      ok: Bool?,
      error: String?,
    )
  end
  
  var code : Int32
  var http : HTTP::Client::Response
  var meta : Meta
#  var rate_limit : RateLimit
  var req : Request

  delegate headers, body, to: http

  def initialize(@http, @req = nil)
    @code = http.status_code
    @meta = Meta.from_json(body) rescue nil
  end

  def success? : Bool
    return false if !http.success?
    return false if !meta?
    return !! meta.ok
  end
  
  def body! : String
    if success?
      return body
    else
      raise "%s: %s" % [code, body]
    end
  end
end
