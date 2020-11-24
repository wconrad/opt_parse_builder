class OptparseBuilder

  # Like OpenStruct, in that it allows access as through either an
  # array or a struct, but raises an error if you try to read a value
  # that has not been set.
  class ArgumentValues

    def initialize
      @h = {}
    end

    def empty?
      @h.empty?
    end

    def has_key?(key)
      @h.has_key?(key.to_sym)
    end

    def []=(key, value)
      @h[key.to_sym] = value
    end

    def [](key)
      @h.fetch(key.to_sym)
    end

    def method_missing(method, *args)
      return super unless has_key?(method)
      self[method]
    end
    
  end
end
