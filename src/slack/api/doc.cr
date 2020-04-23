class Slack::Api::Doc
  var compact = false
  var show_token = false
  
  def initialize(@method : Method, compact : Bool? = nil)
    @compact = compact if !compact.nil?
  end

  def to_s(io : IO)
    name = @method.name? || "(no name)"
    io.puts "%s (%s)" % [name, @method.desc]

    lines   = Array(Array(String)).new
    headers = %w(Argument Example Required Description)
    @method.args.each do |name, arg|
      next if name == "token" && show_token? == false
      required = arg.required ? "Required" : "Optional"
      example  = Pretty.truncate(arg.example, size: compact? ? 20 : 1024)
      desc     = Pretty.truncate(arg.desc   , size: compact? ? 40 : 1024)
      lines << [name, example, required, desc]
    end
    io << Pretty.lines(lines, indent: "  ", headers: headers, delimiter: " ")
  end
end
