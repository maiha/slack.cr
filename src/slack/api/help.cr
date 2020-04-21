class Slack::Api::Help
  var compact = false
  var show_token = false
  
  def initialize(@method : Method, compact : Bool? = nil)
    @compact = compact if !compact.nil?
  end

  def to_s(io : IO)
    name = @method.name? || "(no name)"
    url  = "#{Slack::Client::URL}/api/#{@method.name?}"
    io.puts "API"
    io.puts "  %s (%s)" % [name, url]
    io.puts "  #{@method.desc}"
    io.puts

    lines   = Array(Array(String)).new
    headers = %w(Argument Example Required Description)
    @method.args.each do |name, arg|
      next if name == "token" && show_token? == false
      required = arg.required ? "Required" : "Optional"
      example  = Pretty.truncate(arg.example, size: compact? ? 20 : 1024)
      desc     = Pretty.truncate(arg.desc   , size: compact? ? 40 : 1024)
      lines << [name, example, required, desc]
    end
    io.puts Pretty.lines(lines, headers: headers, delimiter: " ")
  end
end
