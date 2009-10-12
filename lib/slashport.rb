require 'rubygems'
require 'json'
require 'optparse'
require "ostruct"
require "net/http"
require "uri"

module SlashPort
  class Check # class SlashPort::Check
    def initialize(name, cmp, value)
      @name = name
      @value = value
      @cmpstr = cmp
      case cmp
      when ">="
        @cmp = Proc.new { |v| v >= coerce(v, @value) }
      when "<="
        @cmp = Proc.new { |v| v <= coerce(v, @value) }
      when "=="
        @cmp = Proc.new { |v| v == coerce(v, @value) }
      when "!="
        @cmp = Proc.new { |v| v != coerce(v, @value) }
      when "<"
        @cmp = Proc.new { |v| v < coerce(v, @value) }
      when ">"
        @cmp = Proc.new { |v| v > coerce(v, @value) }
      else
        raise "Unknown comparison '#{cmp}'"
      end
    end # def initialize

    def to_s
      return "#{@name} #{@cmpstr} #{@value}"
    end # def to_s

    # if 'a' is an int or float, try to convert b to the same thing
    def coerce(a, b)
      return b.to_i if a.is_a?(Integer)
      return b.to_f if a.is_a?(Float)
      return b
    end # def coerce

    # Turn a string "name cmp value" into a Check.
    # Valid cmp are <, >, <=, >=, and ==
    def self.new_from_string(value)
      return nil unless value =~ /^([A-z0-9_-]+)\s*((?:[><=!]=)|[<>])\s*(.*)$/
      return SlashPort::Check.new($1, $2, $3)
    end # def self.new_from_string

    # Given an attribute, does this check match?
    def match?(attribute)
      match = false
      ["data", "labels"].each do |type|
        if (attribute[type].has_key?(@name) and @cmp.call(attribute[type][@name]))
          match = true
          return match
        end
      end
      return match
    end # def match?
  end # class SlashPort::Check

  class Fetcher # class SlashPort::Fetcher
    def initialize(host, port=4000)
      @host = host
      @port = port
      @scheme = "http"

      @filters = []
      @checks = []
    end # def initialize

    def add_filter(key, value)
      @filters << [key, value]
    end

    def fetch
      url = "#{@scheme}://#{@host}:#{@port}/var.json?#{query}"
      #puts "URL: #{url}"
      response = Net::HTTP.get_response(URI.parse(url))
      if response.code.to_i != 200
        raise "Non-OK http response: #{response.code}"
      end

      return JSON::parse(response.body)
    end # def fetch

    def query
      return @filters.collect { |a,b| "#{a}=#{b}" }.join("&")
    end # def query
  end # class SlashPort::Fetcher

end # module SlashPort
