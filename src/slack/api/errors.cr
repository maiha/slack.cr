class Slack::Api::InvalidParameter < Exception
  getter name   : String
  getter method : Method

  def initialize(@name, @method)
    super("Invalid Parameter: #{name}")
  end
end

class Slack::Api::MethodNotFound < Exception
  getter name : String
  var path : String

  def initialize(@name, @path = nil)
    super("No API catalogs for [#{name}].")
  end
end
