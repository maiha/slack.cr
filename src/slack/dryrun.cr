class Slack::Dryrun < Exception
  forward_missing_to @req

  def initialize(@req : Slack::Request)
    super(to_s)
  end

  def to_s(io : IO)
    io << computed_uri.to_s
  rescue err
    io << err.to_s
  end

  def inspect(io : IO)
    uri = computed_uri
    io.puts "=== plan to send ==========================================="
    io.puts "%s %s" % [method, computed_uri.to_s]
    io.puts "headers: #{headers.to_h.inspect}"
    io.puts "--- body to send -------------------------------------------"
    io.puts body if body.size > 0
    io.puts "------------------------------------------------------------"
  rescue err
    io.puts err.to_s
  end
end
