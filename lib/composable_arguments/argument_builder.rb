class ComposableArguments
  class ArgumentBuilder

    def initialize
      @key = nil
      @default = nil
      @on = []
      @operand_class = nil
      @operand_help_name = nil
      @banner_lines = []
      @separator_lines = []
    end

    def key(v)
      @key = v.to_sym
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

    def optional_operand(help_name: nil)
      @operand_class = OptionalOperandArgument
      @operand_help_name = help_name
    end

    def required_operand(help_name: nil)
      @operand_class = RequiredOperandArgument
      @operand_help_name = help_name
    end

    def splat_operand(help_name: nil)
      @operand_class = SplatOperandArgument
      @operand_help_name = help_name
    end

    def argument
      check_for_build_errors
      bundle = ArgumentBundle.new
      unless @banner_lines.empty?
        bundle << BannerArgument.new(@banner_lines)
      end
      unless @separator_lines.empty?
        bundle << SeparatorArgument.new(@separator_lines)
      end
      if !@on.empty?
        bundle << OptionArgument.new(@key, @default, @on)
      elsif @operand_class
        bundle << @operand_class.new(
          @key,
          @default,
          @operand_help_name,
        )
      else
        if @key || @default
          bundle << ConstantArgument.new(@key, @default)
        end
      end
      bundle.simplify
    end

    private

    def check_for_build_errors
      if !@on.empty? && @operand_class
        raise BuildError,
              "Argument cannot be both an option and an operand"
      end
    end
    
  end
end
