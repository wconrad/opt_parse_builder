class OptparseBuilder
  class OptionalOperandArgument < Argument # :nodoc:

    include FormatsOperandName
    include HasValue

    def initialize(key, default, help_name)
      init_value(key, default)
      @help_name = help_name || key
    end

    def operand_notation
      "[<#{format_operand_name(@help_name)}>]"
    end

    def shift_operand(argv)
      @value = argv.shift
    end

    def optional
      self
    end

    def required
      RequiredOperandArgument.new(@key, @default, @help_name)
    end
    
  end
end
