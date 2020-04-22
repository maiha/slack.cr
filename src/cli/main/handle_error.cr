class Cli::Main
  # default
  protected def handle_error(dryrun : Slack::Dryrun)
    puts dryrun.inspect
  end

  protected def handle_error(err : ApiNotFound)
    show_help("No API is specified.")
    exit 1
  end

  protected def handle_error(err : Slack::Api::MethodNotFound)
    msg = String.build do |s|
      s.puts "#{err}" + (err.path? ? " (path: #{err.path})" : "")
      s.puts
      s.puts "Check that the API name is correct by searching for the following."
      s.puts "  slack-cli --ls #{err.name}"
      s.puts
      s.puts "Or, if it's a new API, you can use it by specifying <catalog_dir>."
      s.puts "  slack-cli -c path/to/methods"
    end
    STDERR.puts msg
    exit 1
  end

  # default
  protected def handle_error(err)
    STDERR.puts err.to_s
    exit 255
  end
end
