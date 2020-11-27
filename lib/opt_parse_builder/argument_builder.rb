module OptParseBuilder

  # Builds arguments using a builder style DSL.  You never create an
  # instance of this class yourself.  Instead, an instance is yielded
  # to you by OptParseBuilder.
  #
  # See the README for examples.
  class ArgumentBuilder

    def initialize # :nodoc:
      @key = nil
      @default = nil
      @on = []
      @operand_class = nil
      @operand_help_name = nil
      @banner_lines = []
      @separator_lines = []
    end

    # Set the argument's key.  Accepts either a string or a symbol.
    def key(v)
      @key = v.to_sym
    end

    # Set the argument's default value.  This it the value an argument
    # has before parsing, or if parsing does not set the value.
    #
    # If an argument's default value is not explicitly set, then the
    # default value is `nil`.
    def default(v)
      @default = v
    end

    # Declares the argument to be an option that is handled by
    # OptParse.  The arguments are passed to OptParse exactly as you
    # give them, except that the string _DEFAULT_ is replaced with the
    # argument's default value.
    #
    # Simple example:
    #
    #     arg = OptParseBuilder.build_argument do |arg|
    #       arg.key :quiet
    #       arg.on "-q", "Be very veru quiet", "We're hunting rabbit!"
    #     end
    #
    # You may split up a long argument list by calling this method
    # more than once.  This is equivalent to the above:
    #
    #     arg = OptParseBuilder.build_argument do |arg|
    #       arg.key :quiet
    #       arg.on "-q", "Be very veru quiet",
    #       arg.on "We're hunting rabbit!"
    #     end
    #
    # So that the option's help may print the default without having
    # to duplicate it, the string _DEFAULT_ is replaced with the
    # argument's default value:
    #
    #     arg = OptParseBuilder.build_argument do |arg|
    #       arg.key :size
    #       arg.default 1024
    #       arg.on "--size=N", Integer,
    #       arg.on "Size in bytes (default _DEFAULT_)"
    #     end
    #
    # When the `--help` text for this argument is printed, it will
    # read:
    #
    #     --size-N               Size in bytes (default 1024)
    def on(*option_args)
      @on.concat(option_args)
    end

    # Add to the banner text shown first in the --help output.  You
    # may call this more than once; each call adds another line of
    # text to the banner.
    #
    # Any type of argument may have banner text.
    #
    # See also OptParseBuilder#banner
    def banner(line)
      @banner_lines << line
    end

    # Add to the separator text shown last in the --help output.  You
    # may call this more than once; each call adds another line of
    # text to the separator.
    #
    # Any type of argument may have separator text.
    #
    # See also OptParseBuilder#separator
    def separator(line)
      @separator_lines << line
    end

    # Declare the operand to be an optional operand.  An optional
    # operand consumes one argument.  If the argument is not present,
    # value is either the default (if provided), or nil (if no default
    # was provided).
    def optional_operand(help_name: nil)
      check_operand_class_not_set
      @operand_class = OptionalOperandArgument
      @operand_help_name = help_name
    end

    # Declare the operand to be a required operand.  A required
    # operand consumes one argument, generating an error if there is
    # not one.
    def required_operand(help_name: nil)
      check_operand_class_not_set
      @operand_class = RequiredOperandArgument
      @operand_help_name = help_name
    end

    # Declare the argument to be a "splat" operand.  A splat operand
    # consumes all remaining arguments.
    def splat_operand(help_name: nil)
      check_operand_class_not_set
      @operand_class = SplatOperandArgument
      @operand_help_name = help_name
    end

    def argument # :nodoc:
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

    def check_operand_class_not_set
      if @operand_class
        raise BuildError, "Argument is already an operand"
      end
    end

    def check_for_build_errors
      if !@on.empty? && @operand_class
        raise BuildError,
              "Argument cannot be both an option and an operand"
      end
    end
    
  end
end
