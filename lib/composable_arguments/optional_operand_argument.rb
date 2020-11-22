class ComposableArguments
  class OptionalOperandArgument < Argument

    attr_reader :key
    attr_reader :value

    def initialize(key, default)
      unless key
        raise BuildError, "option requires a key"
      end
      @key = key
      @default = default
      reset
    end

    def operand_notation
      "[<#{@key}>]"
    end

    def shift_operand(argv)
      @value = argv.shift
    end
      
    def reset
      @value = @default
    end
    
  end
end
