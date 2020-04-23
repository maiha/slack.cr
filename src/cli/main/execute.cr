class Cli::Main
  protected def execute!
    body = ""
    req  = client.request(method: method, params: params, body: body)
    res  = client.execute(req)

    res.http.success?   || abort "%s %s" % [res.code, res.body]
    res.meta?.try(&.ok) || abort res.body.to_s

    puts res.body
  end
end
