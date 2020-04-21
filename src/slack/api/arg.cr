class Slack::Api::Arg
  JSON.mapping(
    required: Bool,
    example: String,
    desc: String,
  )

  def to_s(io : IO)
    mark = required ? "REQUIRED" : "OPTIONAL"
    io.puts "[%s] (example: %s) # %s" % [mark, example, desc]
  end
end
