class ComposableArguments
  class ConstantArgument < Argument

    attr_reader :key
    attr_reader :value

    def initialize(key, value)
      unless key
        raise BuildError, "default requires a key"
      end
      @key = key
      @value = value
    end

    def add_to_values(argument_values)
      argument_values[@key] = value
    end
    
  end
end
