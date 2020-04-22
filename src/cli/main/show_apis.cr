class Cli::Main
  protected def show_apis
    catalog.each do |method|
      next if @api && !method.name.includes?(api)
      puts method.name
    end
  end
end
