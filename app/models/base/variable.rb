module SlashPort
  class Variable
    attr_reader :method
    attr_reader :description

    def initialize(method, description)
      @method = method
      @description = description
    end
  end # class Variable
end # module SlashPort
