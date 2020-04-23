class Cli::Main
  protected def show_help(msg : String? = nil, exit : Int32 = 0) : Nil
    if @api && method?
      puts Slack::Api::Help.new(method, compact: !verbose?)
    else
      puts parser?.to_s
    end

    if msg
      puts
      puts msg
    end

    exit(exit)
  end
end
