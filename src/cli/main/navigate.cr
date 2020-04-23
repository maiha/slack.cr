class Cli::Main
  protected def navigate : Nil
    unless @api
      show_help(exit: 1)
    end

    bound_params = Hash(String, String).new
    unbound_args = method.named_args(token: false)

    # bind params
    params.each do |key, val|
      if method.args[key]?
        bound_params[key] = val
        unbound_args.reject!(&.name.== key)
      else
        raise ArgumentError.new(navigate_invalid_paramter_message(key, method))
      end
    end

    # bind args
    args.each_with_index do |arg, i|
      if na = unbound_args.shift?
        bound_params[na.name] = arg
      else
        # too much arguments found
        raise ArgumentError.new(navigate_too_much_args_message(i, method))
      end
    end

    # check unbound_args contains required
    unbound_args.each do |na|
      if na.arg.required
        raise ArgumentError.new(navigate_missing_args_message(na, method))
      end
    end

    # ok. replace params by our bound_params
    @params = bound_params
    execute!
  end

  private def navigate_current_parts : Array(String)
    ary = ["slack-cli"]
    if v = @api
      ary << v
    end
    params.each do |key, val|
      ary << "-d #{key}=#{val}"
    end
    ary.concat(args)
  end
  
  private def navigate_invalid_paramter_message(key, method) : String
    current_parts = navigate_current_parts
    correct_parts = current_parts.map{|v| v.starts_with?("-d #{key}=") ? ("   " + "^" * key.size) : ""}
    expected_name = method.named_args(token: false).map(&.name).join(" ")

    table = Pretty.lines([current_parts, correct_parts], indent: "    ", delimiter: " ").chomp
    
    <<-EOF
      Invalid parameter: '#{key}'

      #{table}
      See help for details.

          slack-cli #{method.name} -h

      EOF
  end
  
  private def navigate_too_much_args_message(arg_i, method) : String
    current_parts = navigate_current_parts
    correct_parts = current_parts.map_with_index{|v, i|
      if (i >= 2) && !v.starts_with?("-d ") && (i == arg_i + 2)
        "^" * v.size
      else
        ""
      end
    }

    table = Pretty.lines([current_parts, correct_parts], indent: "    ", delimiter: " ").chomp
    given = args.size

    min = method.named_args(token: false, required: true, optional: false).size - params.size
    max = method.named_args(token: false, required: true, optional: true ).size - params.size

    expected = (min == max) ? min : "#{min}..#{max}"
      
    <<-EOF
      Too much arguments (given #{given}, expected #{expected})

      #{table}
      See help for details.

          slack-cli #{method.name} -h

      EOF
  end

  private def navigate_missing_args_message(na, method) : String
    current_parts = Slack::Api::Help.new(method).usage_parts
    correct_parts = current_parts.map{|v|
      if v == "<#{na.name}>"
        "^" * v.size
      else
        ""
      end
    }

    table = Pretty.lines([current_parts, correct_parts], indent: "    ", delimiter: " ").chomp

    <<-EOF
      Missing parameter '#{na.name}'

      #{table}
      See help for details.

          slack-cli #{method.name} -h

      EOF
  end
end
