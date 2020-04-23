record Slack::Api::NamedArg,
       name : String,
       arg  : Arg do

  def to_s(io : IO)
    if arg.required
      io << "<#{name}>"
    else
      io << "[#{name}]"
    end
  end
end
