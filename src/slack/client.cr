require "./dryrun"
require "./request"
require "./response"
require "./executable"

class Slack::Client
  URL = "https://slack.com"

  # Auth
  var token : String

  # HTTP
  var uri             : URI     = URI.parse(URL)
  var user_agent      : String  = "github.com/maiha/slack.cr"
  var dns_timeout     : Float64 = 3.0
  var connect_timeout : Float64 = 5.0
  var read_timeout    : Float64 = 300.0
    
  var logger : Pretty::Logger = Pretty::Logger.new(nil)
  var dryrun : Bool = false

  def initialize(@token, url : String? = nil, @logger : Logger? = nil)
    self.url = url if url
  end

  ######################################################################
  ### Execute

  include Executable
    
  ######################################################################
  ### Accessor methods
    
  def authorized?
    return false if token.empty?
    return true
  end

  def url=(v : String)
    @uri = URI.parse(v)
  end
end
