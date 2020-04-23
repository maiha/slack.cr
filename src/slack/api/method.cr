require "./arg"

class Slack::Api::Method
  var name : String

  JSON.mapping(
    desc: String,
    args: Hash(String, Arg),
  )

  def token? : Arg?
    args["token"]?
  end

  def named_args(token = true, required = true, optional = true) : Array(NamedArg)
    ary = Array(NamedArg).new
    args.each do |name, arg|
      next if !token && name == "token"
      next if !required &&  arg.required
      next if !optional && !arg.required
      ary << NamedArg.new(name, arg)
    end
    return ary
  end
  
  def path : String
    "/api/#{name}"
  end
end
