class Cli::Main
  protected def show_version
    puts "#{PROGRAM} #{VERSION} #{TARGET_TRIPLE} crystal-#{Crystal::VERSION}"
    puts "API catalog: #{CATALOG_INFO}"
  end
end
