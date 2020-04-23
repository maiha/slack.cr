require "./method"

module Slack::Api
  abstract class Catalog
    include Enumerable(Method)

    var methods = Hash(String, Try(Method)).new

    def [](name : String) : Method
      try(name).get
    end

    def each : Nil
      methods.each do |name, try|
        if method = try.get?
          yield method
        end
      end
    end
    
    abstract def try(name : String) : Try(Method)
  end

  class DynamicCatalog < Catalog
    def initialize(@dir : String)
    end

    def try(name : String) : Try(Method)
      Try(Method).try {
        path = File.join(@dir, "#{name}.json")
        if File.exists?(path)
          json = File.read(path)
          Method.from_json(json).tap{|v| v.name = name}
        else
          raise MethodNotFound.new(name, path)
        end
      }
    end
  end

  class StaticCatalog < Catalog
    def try(name : String) : Try(Method)
      Try(Method).try {
        if try = methods[name]?
          try.get
        else
          raise MethodNotFound.new(name)
        end
      }
    end

    def register_json(name, json)
      methods[name] = Try(Method).try {
        begin
          Method.from_json(json).tap{|v| v.name = name}
        rescue err
          raise "[BUG] parse error: #{name}.json (#{err})"
        end
      }
    end

    def self.bundled : StaticCatalog
      raise "[BUG] No bundled catalogs. Please specify <catalog_dir>."
    end

    def self.from_tsv(buf) : StaticCatalog
      store = new
      lineno = 0
      CSV.each_row(buf, '\t') do |row|
        lineno += 1
        case row.size
        when 0 # ignores (maybe EOF)
        when 2 # Success
          name = row[0]
          json = row[1]
          store.register_json(name, json)
        else   # Failure (BUG of generator)
          name = row[0]
          store.methods[name] = Try(Method).try {
            raise "Invalid TSV (expected 2 columns, but line:#{lineno} has #{row.size})"
          }
        end
      end
      return store
    end
  end
end
