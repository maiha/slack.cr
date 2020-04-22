class Cli::Main
  protected def build_parser
    OptionParser.new do |parser|
      parser.banner = "usage: #{PROGRAM} [options...] <api> [<args>]"
      parser.on("--ls", "List API names in catalog") { @command = Command::SHOW_APIS }
      parser.on("-a", "--token <token>", "Specify token without reading from ENV") {|v| client.token = v.presence }
      parser.on("-d", "--data <key=val>", "Specify parameters for API args") {|v| add_params(v) }
      parser.on("--dns-timeout <seconds>"    , "Maximum time allowed for DNS lookup") {|v| client.dns_timeout = v.to_f64 }
      parser.on("--connect-timeout <seconds>", "Maximum time allowed for connection") {|v| client.connect_timeout = v.to_f64 }
      parser.on("--read-timeout <seconds>"   , "Maximum time allowed for read"      ) {|v| client.read_timeout = v.to_f64 }
      parser.on("-c", "--catalog_dir <dir>", "Specify <catalog_dir> for new API") {|v| self.catalog = Slack::Api::DynamicCatalog.new(dir: v) }
      parser.on("-n", "--dryrun" , "Dryrun mode"   ) { client.dryrun = true }
      parser.on("-v", "--verbose", "Verbose mode"  ) { self.verbose = true }
      parser.on("-V", "--version", "Show version"  ) { show_version; exit(0) }
      parser.on("-h", "--help"   , "Show this help") { @command = Command::SHOW_HELP }
    end
  end

  protected def add_params(v : String)
    case v
    when /^(.*?)=(.*)$/
      params[$1] = $2
    else
      abort "parameter must contain '=' like 'user=12345'"
    end
  end
end
