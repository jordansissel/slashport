module SlashPort
  class Variable
    attr_reader :handler
    attr_reader :doc
    attr_reader :sortkeys

    def initialize(handler, doc, sortkeys=[])
      @handler = handler
      @doc = doc
      @sortkeys = sortkeys
    end
  end # class Variable
end # module SlashPort
