class OptParseBuilder

  # Like OpenStruct, in that it allows access as through either a Hash
  # or a Struct, but raises an error if you try to read a value that
  # has not been set.
  #
  # Strings and symbols may be interchanged freely for hash access.
  #
  # A value may only by set using hash syntax:
  #
  #     arg_values = ArgumentValues.new
  #     arg_values[:one] = 1
  #     arg_values["two"] = 2
  #
  # But may be retrieved using hash syntax:
  #
  #     arg_values["one"]    # => 1
  #     arg_values[:two]     # => 2
  #
  # or struct syntax:
  #
  #     arg_values.one    # => 1
  #     arg_values.two    # => 2
  class ArgumentValues

    # Create an empty instance.
    def initialize
      @h = {}
    end

    # Return true if the collection is empty.
    def empty?
      @h.empty?
    end

    # Return true if the collection contains the key, which may be
    # either a symbol or a string.
    def has_key?(key)
      @h.has_key?(key.to_sym)
    end

    # Set a key to a value.  The key may be either a string or a
    # symbol.
    def []=(key, value)
      @h[key.to_sym] = value
    end

    # Get a value.  The key may be either a string or a symbol.
    # Raises KeyError if the collection does not have that key.
    def [](key)
      @h.fetch(key.to_sym)
    end

    def method_missing(method, *args) # :nodoc:
      return super unless has_key?(method)
      self[method]
    end
    
  end
end
