class Cli::Main
  protected def execute!
    client.token? || abort "Please specify <TOKEN> by arg: --token or env: SLACK_TOKEN"

    body = ""
    req  = client.request(method: method, params: params, body: body)
    res  = client.execute(req)

    res.http.success?   || abort "%s %s" % [res.code, res.body]
    res.meta?.try(&.ok) || abort res.body.to_s

    puts res.body
  end
end
