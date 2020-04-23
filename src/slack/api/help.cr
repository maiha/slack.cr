class Slack::Api::Help
  var compact = false
  
  def initialize(@method : Method, compact : Bool? = nil)
    @compact = compact if !compact.nil?
  end

  def api : String
    @method.name? || "(???)"
  end

  def usage_parts : Array(String)
    return ["slack-cli", api] + @method.named_args(token: false).map(&.to_s)
  end

  def usage : String
    return "usage: " + usage_parts.join(" ")
  end

  def to_s(io : IO)
    named_args = @method.named_args(token: false)

    io.puts usage

    io.puts
    io.puts "parameters:"
    lines = Array(Array(String)).new
    named_args.each do |na|
      name = na.name
      desc = Pretty.truncate(na.arg.desc   , size: compact? ? 60 : 1024)
      lines << [name, desc]
    end
    io.puts Pretty.lines(lines, indent: "    ", delimiter: "    ")

    io.puts
    io.puts "examples:"
    io.puts "    slack-cli #{api} " + named_args.map{|na| "-d %s=%s" % [na.name, Pretty.truncate(na.arg.example, size: compact? ? 15 : 1024)]}.join(" ")
    io.puts "    slack-cli #{api} " + named_args.map{|na| Pretty.truncate(na.arg.example, size: compact? ? 20 : 1024)}.join(" ")
    if named_args.any?(&.arg.required) && named_args.any?{|na| !na.arg.required}
      io.puts "    slack-cli #{api} " + named_args.select(&.arg.required).map{|na| Pretty.truncate(na.arg.example, size: compact? ? 20 : 1024)}.join(" ")
    end
  end
end
