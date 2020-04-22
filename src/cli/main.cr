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
  var api     : String        = raise ApiNotFound.new
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

  rescue err
    handle_error(err)
  end  
end

Cli::Main.new.run
