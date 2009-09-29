module SlashPort
  class Component
    # Keep a registry of subclasses for autoregistration
    class << self
      @@subclasses = []

      # See Class#inherited for what this method 
      def inherited(subclass)
        puts "#{subclass.name} < #{self.name}"
        @@subclasses << subclass

        if subclass.respond_to?(:class_initialize)
          subclass.class_initialize
        end
      end # def self.inherited

      # class-level to easily map a variable name to a method
      def variable(name, method)
        puts "#{self.name}: variable #{name}"
        # class-level instance variable @variables
        self.class_eval do
          @variables[name] = method
        end
      end # def self.variable
 
      # class-level initialization. This is called when ruby first
      # creates this class object, a hack made possible by
      # overriding Class#inherited (see 'def inherited' above).
      def class_initialize
        puts "#{self}::class_initialize"

        self.class_eval do
          @variables = Hash.new
        end
      end # def.class_initialize

      # Show me all subclasses of SlashPort::Component
      def all
        return @@subclasses
      end # def self.all
    end # class << self (SlashPort::Component)
  end # module Component
end # module SlashPort

class Foo < SlashPort::Component
  variable "test", :VariableTest
  variable "bar", :VariableTest

  def VariableTest
    return 123
  end
end
