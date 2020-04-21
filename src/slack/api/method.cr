require "./arg"

class Slack::Api::Method
  var name : String

  JSON.mapping(
    desc: String,
    args: Hash(String, Arg),
  )

  def path : String
    "/api/#{name}"
  end
end
