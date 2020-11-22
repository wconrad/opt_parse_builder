class ComposableArguments
  class RequiredOperandArgument < Argument

    attr_reader :key
    attr_reader :value

    def initialize(key, default, help_name)
      unless key
        raise BuildError, "option requires a key"
      end
      @key = key
      @default = default
      @help_name = help_name || key
      reset
    end

    def operand_notation
      "<#{@help_name}>"
    end

    def shift_operand(argv)
      @value = argv.shift
      unless @value
        raise OptionParser::MissingArgument, operand_notation
      end
    end
      
    def reset
      @value = @default
    end
    
  end
end
