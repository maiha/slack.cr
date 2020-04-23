class Cli::Main
  protected def show_apis : Nil
    catalog.each do |method|
      next if @api && !method.name.downcase.includes?(api.downcase)

      if verbose?
        puts Slack::Api::Doc.new(method, compact: true)
        puts
      else
        puts method.name
      end
    end
  end
end
