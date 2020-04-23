class Cli::Main
  # default
  protected def handle_error(dryrun : Slack::Dryrun)
    puts dryrun.inspect
  end

  protected def handle_error(err : ArgumentError)
    STDERR.puts err.to_s
    exit 1
  end

  protected def handle_error(err : ApiNotFound)
    show_help("No API is specified.")
    exit 1
  end

  protected def handle_error(err : Slack::Api::MethodNotFound)
    STDERR.puts "No API found for '#{err.name}'. See 'slack-cli --ls'."
    exit 1
  end

  protected def handle_error(err : Slack::Client::TokenNotFound)
    STDERR.puts "No SLACK_TOKEN is specified. See 'slack-cli --help'."
    exit 3
  end

  # default
  protected def handle_error(err)
    STDERR.puts(err.to_s.presence || err.class.name)
    err.inspect_with_backtrace(STDERR) if verbose
    exit 255
  end
end
