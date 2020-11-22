class ComposableArguments
  class ArgumentBuilder

    def initialize
      @key = nil
      @default = nil
      @on = []
      @operand = nil
      @banner_lines = []
      @separator_lines = []
    end

    def key(v)
      @key = v
    end

    def default(v)
      @default = v
    end

    def on(*option_args)
      @on.concat(option_args)
    end

    def banner(line)
      @banner_lines << line
    end

    def separator(line)
      @separator_lines << line
    end

    def optional_operand
      @operand = :optional
    end

    def argument
      bundle = ArgumentBundle.new
      unless @banner_lines.empty?
        bundle << BannerArgument.new(@banner_lines)
      end
      unless @separator_lines.empty?
        bundle << SeparatorArgument.new(@separator_lines)
      end
      if !@on.empty? && @operand
        raise BuildError,
              "Argument cannot be both an option and an operand"
      end
      if @on.empty?
        case @operand
        when :optional
          bundle << OptionalOperandArgument.new(@key, @default)
        else
          if @key || @default
            bundle << ConstantArgument.new(@key, @default)
          end
        end
      else
        bundle << OptionArgument.new(@key, @default, @on)
      end
      bundle.simplify
    end

  end
end
