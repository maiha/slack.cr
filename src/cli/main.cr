# stdlib
require "option_parser"

# shards
require "shard"

# slack.cr
require "../slack"

# cli
require "./**"
require "./main/**"
require "../../gen/catalog"

class Cli::Main
  var command : Command       = Command::EXECUTE
  var parser  : OptionParser  = build_parser
  var client  : Slack::Client = Slack::Client.new(ENV["SLACK_TOKEN"]?)
  var catalog : Slack::Api::Catalog = Slack::Api::StaticCatalog.bundled
  var method  : Slack::Api::Method = catalog[api]
  var api     : String        = abort "No API is specified."
  var args    = Array(String).new
  var params  = Hash(String, String).new
  var verbose = false

  def run
    parser.parse
    @api  = ARGV.shift?
    @args = ARGV

    case command
    when .show_help?
      show_help(exit: 0)
    when .show_apis?
      show_apis
    when .execute?      
      execute!
    end

  rescue dryrun : Slack::Dryrun
    puts dryrun.inspect
  rescue err : Slack::Api::MethodNotFound
    msg = String.build do |s|
      s.puts "#{err}" + (err.path? ? " (path: #{err.path})" : "")
      s.puts
      s.puts "Check that the API name is correct by searching for the following."
      s.puts "  #{PROGRAM} --ls #{err.name}"
      s.puts
      s.puts "Or, if it's a new API, you can use it by specifying <catalog_dir>."
      s.puts "  #{PROGRAM} -c path/to/methods"
    end
    STDERR.puts msg
    exit 1
  rescue err
    STDERR.puts err.to_s
    exit 255
  end  
end

Cli::Main.new.run
