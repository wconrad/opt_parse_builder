class OptParseBuilder
  class SplatOperandArgument < Argument # :nodoc:

    include FormatsOperandName
    include HasValue

    def initialize(key, default, help_name)
      init_value(key, default)
      @help_name = help_name || key
    end

    def operand_notation
      "[<#{format_operand_name(@help_name)}>...]"
    end

    def shift_operand(argv)
      @value = argv.dup
      argv.clear
    end
    
  end
end
