{% begin %}
TARGET_TRIPLE = "{{`crystal -v | grep x86_64 | cut -d: -f2`.strip}}"
CATALOG_INFO  = "{{`cat gen/catalog.info`.strip}}"
{% end %}

require "option_parser"
require "csv"
require "shard"
require "try"
require "../slack"
require "./**"
require "../../gen/catalog"

class Cli::Main
  PROGRAM = File.basename(PROGRAM_NAME)
  VERSION = Shard.version

  var parser  : OptionParser  = build_parser
  var client  : Slack::Client = Slack::Client.new(ENV["SLACK_TOKEN"]?)
  var catalog : Slack::Api::Catalog = Slack::Api::StaticCatalog.bundled
  var method  : Slack::Api::Method
  var api     : String
  var args    = Array(String).new
  var params  = Hash(String, String).new
  var help    = false
  var verbose = false

  def run
    parser.parse
    @api  = ARGV.shift?
    @args = ARGV

    show_help(exit: 0) if help

    client.token? || abort "Please specify <TOKEN> by arg: --token or env: SLACK_TOKEN"
    catalog?      || abort "Please specify <CATALOG_DIR> by arg: -c"
    api?          || show_help("No API is specified.", exit: 1)

    @method = catalog[api]
    execute!

  rescue dryrun : Slack::Dryrun
    puts dryrun.inspect
  rescue err
    STDERR.puts err.to_s
    exit 255
  end  

  private def execute!
    body = ""
    req  = client.request(method: method, params: params, body: body)
    res  = client.execute(req)

    res.http.success?   || abort "%s %s" % [res.code, res.body]
    res.meta?.try(&.ok) || abort res.body.to_s

    puts res.body
  end
  
  private def build_parser
    OptionParser.new do |parser|
      parser.banner = "usage: #{PROGRAM} [options...] <api> [<args>]"
      parser.on("-a", "--token <token>", "Specify token without reading from ENV") {|v| client.token = v.presence }
      parser.on("-d", "--data <key=val>", "Specify parameters for API args") {|v| add_params(v) }
      parser.on("--dns-timeout <seconds>"    , "Maximum time allowed for DNS lookup") {|v| client.dns_timeout = v.to_f64 }
      parser.on("--connect-timeout <seconds>", "Maximum time allowed for connection") {|v| client.connect_timeout = v.to_f64 }
      parser.on("--read-timeout <seconds>"   , "Maximum time allowed for read"      ) {|v| client.read_timeout = v.to_f64 }
      parser.on("-c", "--catalog_dir <dir>", "Specify <catalog_dir> for new API") {|v| self.catalog = Slack::Api::DynamicCatalog.new(dir: v) }
      parser.on("-n", "--dryrun" , "Dryrun mode"   ) { client.dryrun = true }
      parser.on("-v", "--verbose", "Verbose mode"  ) { self.verbose = true }
      parser.on("-V", "--version", "Show version"  ) { show_version; exit(0) }
      parser.on("-h", "--help"   , "Show this help") { self.help = true }
    end
  end

  private def add_params(v : String)
    case v
    when /^(.*?)=(.*)$/
      params[$1] = $2
    else
      abort "parameter must contain '=' like 'user=12345'"
    end
  end

  private def show_version
    puts "#{PROGRAM} #{VERSION} #{TARGET_TRIPLE} crystal-#{Crystal::VERSION}"
    puts "API catalog: #{CATALOG_INFO}"
  end

  private def show_help(msg : String? = nil, exit : Int32? = nil)
    if method?
      puts Slack::Api::Help.new(method, compact: !verbose?)
    else
      puts parser?.to_s
    end

    if msg
      puts
      puts msg
    end

    if code = exit
      exit(code)
    end
  end
end

Cli::Main.new.run
