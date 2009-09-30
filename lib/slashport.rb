require 'rubygems'
require 'rack'

module SlashPort
  class Component
    # Keep a registry of subclasses for autoregistration
    class << self
      @@subclasses = []
      attr_reader :variables

      # See Class#inherited for what this method 
      def inherited(subclass)
        puts "#{subclass.name} inherits #{self.name}"
        @@subclasses << subclass

        if subclass.respond_to?(:class_initialize)
          subclass.class_initialize
        end
      end # def self.inherited

      # class-level to easily map a variable name to a method
      def variable(name, method, description=nil)
        if description == nil
          raise "Variable #{self.name}/#{name} has no description"
        end
        puts "#{self.name}: new variable #{name}"

        # remember: this is a class-level instance variable
        @variables[name] = method
        puts description
      end # def self.variable
 
      # class-level initialization. This is called when ruby first
      # creates this class object, a hack made possible by
      # overriding Class#inherited (see 'def inherited' above).
      def class_initialize
        puts "#{self}::class_initialize"
        # remember: this is a class-level instance variable
        @variables = Hash.new
      end # def.class_initialize

      # Show me all subclasses of SlashPort::Component
      def all
        return @@subclasses
      end # def self.all
    end # class << self (SlashPort::Component)

    def initialize

    end

    def variables
      data = Hash.new
      self.class.variables.each do |name, method|
        data[name] = self.send(method)
      end
      return data
    end
  end # module Component
end # module SlashPort

class Foo < SlashPort::Component
  variable "test", :VariableTest, <<-doc
    Test documentation
  doc

  variable "bar", :VariableTest, <<-doc
    Bar bazzle!
  doc

  def VariableTest
    return 123
  end
end

x = Foo.new
puts x.variables.inspect

