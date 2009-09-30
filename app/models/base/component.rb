module SlashPort
  class Component
    @@subclasses = Array.new
    @@components = Array.new

    def variables
      return self.class.variables
    end

    def configs
      return self.class.configs
    end

    def get_variables(filter=nil)
      data = Hash.new
      self.variables.each do |name, var|
        result = self.send(var.method)
        data[name] = result
      end
      return data
    end

    # See Class#inherited for what this method 
    def self.inherited(subclass)
      puts "#{subclass.name} inherits #{self.name}"
      @@subclasses << subclass

      if subclass.respond_to?(:class_initialize)
        subclass.class_initialize
      end
    end # def self.inherited

    # class-level to easily map a variable name to a method
    def self.variable(name, method, description=nil)
      if description == nil
        raise "Variable #{self.name}/#{name} has no description"
      end
      puts "#{self.name}: new variable #{name}"

      # remember: this is a class-level instance variable
      @variables[name] = Variable.new(method, description)
    end # def self.variable

    def self.multivariable(name, method, description=nil)
      if description == nil
        raise "Variable #{self.name}/#{name} has no description"
      end
      puts "#{self.name}: new multivariable #{name}"

      # remember: this is a class-level instance variable
      @variables[name] = MultiVariable.new(method, description)
    end # def self.multivariable

    def self.variables(filter=nil)
      return @variables
    end

    # class-level to easily map a variable name to a method
    def self.config(name, method, description=nil)
      if description == nil
        raise "Config #{self.name}/#{name} has no description"
      end
      puts "#{self.name}: new config #{name}"

      # remember: this is a class-level instance variable
      @configs[name] = method
    end # def self.config

    def self.configs(filter=nil)
      return @configs
    end

    # class-level initialization. This is called when ruby first
    # creates this class object, a hack made possible by
    # overriding Class#inherited (see 'def inherited' above).
    def self.class_initialize
      puts "#{self}::class_initialize"
      # remember, this is a class-level instance variable
      @variables = Registry.new
      @configs = Registry.new
      @label = self.name.split("::")[-1].downcase
    end # def.class_initialize

    # Show me all subclasses of SlashPort::Component
    def self.components
      if @@components.length == 0
        @@subclasses.each do |klass|
          @@components << klass.new
        end
      end
      return @@components
    end # def self.components

    def self.get_variables
      data = Hash.new
      self.components.each do |component|
        data[component.class.label] = component.get_variables
      end
      return data
    end

    def self.label
      return @label
    end
  end # class Component
end # module SlashPort
