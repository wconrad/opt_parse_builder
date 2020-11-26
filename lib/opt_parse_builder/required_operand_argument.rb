module OptParseBuilder
  class RequiredOperandArgument < Argument # :nodoc:

    include FormatsOperandName
    include HasValue

    def initialize(key, default, help_name)
      init_value(key, default)
      @help_name = help_name || key
    end

    def operand_notation
      "<#{format_operand_name(@help_name)}>"
    end

    def shift_operand(argv)
      @value = argv.shift
      unless @value
        raise OptionParser::MissingArgument, operand_notation
      end
    end

    def optional
      OptionalOperandArgument.new(@key, @default, @help_name)
    end

    def required
      self
    end
    
  end
end
