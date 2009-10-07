
module SlashPort
  class Component
    @@subclasses = Array.new
    @@components = Array.new

    def attributes
      return self.class.attributes
    end

    def configs
      return self.class.configs
    end

    def get_attributes(filter=nil)
      get_things(attributes, filter)
    end

    def get_configs(filter=nil)
      get_things(configs, filter)
    end

    def _want(value, pattern)
      if pattern.is_a?(Regexp)
        return !!(!pattern or value =~ pattern)
      else
        return !!(!pattern or value == pattern)
      end
    end

    def get_things(thing, filter=nil)
      return unless _want(self.class.label, filter["component"])

      data = []

      thing.each do |section, var|
        next unless _want(section, filter["section"])
        results = self.send(var.handler)
        results = [results] if !results.is_a?(Array)

        results.each do |result|
          result.labels["component"] = self.class.label
          result.labels["section"] = section

          keep = true
          filter.each do |filterkey,filtervalue|
            want = _want(result.labels[filterkey], filtervalue)
            if !want
              keep = false
              break
            end
          end

          data << result if keep
        end
      end
      return data
    end

    def path(*names)
      return [self.class.label, *names].join("/")
    end

    # See Class#inherited for what this method 
    def self.inherited(subclass)
      puts "#{subclass.name} inherits #{self.name}"
      @@subclasses << subclass

      if subclass.respond_to?(:class_initialize)
        subclass.class_initialize
      end
    end # def self.inherited

    # class-level to easily map a attribute name to a method
    # arguments:
    #   :name => attribute name
    #   :handler => method handler name
    #   :doc => attribute documentation
    #   :sort => [optional] array of keys for sort (used with var.text output)
    def self.attribute(options = {})
      if options[:doc] == nil
        raise "Attribute #{self.name}/#{name} has no description"
      end
      name = options[:name]
      puts "#{self.name}: new attribute #{name}"
      options[:sort] ||= []

      # remember: this is a class-level instance attribute
      @attributes[options[:name]] = Attribute.new(options[:handler], options[:doc], options[:sort])
    end # def self.attribute

    # class-level to easily map a variable name to a handler
    def self.config(name, handler, description=nil)
      if description == nil
        raise "Config #{self.name}/#{name} has no description"
      end
      puts "#{self.name}: new config #{name}"

      # remember: this is a class-level instance variable
      @configs[name] = Variable.new(handler, description)
    end # def self.config

    def self.configs(filter=nil)
      return @configs
    end

    def self.attributes(filter=nil)
      return @attributes
    end

    # class-level initialization. This is called when ruby first
    # creates this class object, a hack made possible by
    # overriding Class#inherited (see 'def inherited' above).
    def self.class_initialize
      puts "#{self}::class_initialize"
      # remember, this is a class-level instance attribute
      @attributes = Registry.new
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

    def self.get_things(thing, filter=nil)
      data = []
      self.components.each do |component|
        result = component.send("get_#{thing}", filter)
        if result
          data += result
        end
      end
      return data
    end

    def self.get_attributes(filter=nil)
      return self.get_things("attributes", filter)
    end

    def self.get_configs(filter=nil)
      return self.get_things("configs", filter)
    end

    def self.label
      return @label
    end
  end # class Component
end # module SlashPort
