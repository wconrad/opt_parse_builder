class OptParseBuilder

  # Builds arguments using a builder style DSL.  You never create an
  # instance of this class yourself.  Instead, an instance is yielded
  # to you by OptParseBuilder.
  #
  # # Argument building examples
  #
  # Most of these examples use a shorthand where the surrounding code
  # is not shown:
  #
  #     arg.key = :foo
  #     arg.on "-f"
  #
  # With the surrounding code, that would be this:
  #
  #     arg = OptParseBuilder.build_argument do |arg|
  #       arg.key = :foo
  #       arg.on = "-f"
  #     end
  #
  # or this:
  #
  #     parser = OptparserBuilder.new do |parser|
  #       parser.add do |arg|
  #         arg.key = :foo
  #         arg.on = "-f"
  #       end
  #     end
  #
  # ## Null argument
  #
  # A null argument, having no value or visible effect:
  #
  #     OptParseBuilder.build_argument do |arg|
  #     end
  #
  # This has little value to you, but it fell out of the design for
  # free, and it is useful in the implementation.
  #
  # ## Banner only
  #
  # An argument with only banner text (but see OptParseBuilder#banner
  # for the usual way to do this).  "Banner" is how OptParse describes
  # text that appears at the top of the --help output.
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.banner "Some banner text"
  #       arg.banner "A second line of banner text"
  #       arg.banner <<~BANNER
  #         A third line
  #         A fourth line
  #       BANNER
  #     end
  #
  # Banner text can be added to any argument.
  #
  # ## Separator only
  #
  # An argument with only separator text (but see
  # OptParseBuilder#banner for the usual way to do this).  "Separator"
  # is how OptParse describes text that appears at the bottom of the
  # --help output.
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.serparator "Separator text"
  #       arg.serparator "A second line of separator text"
  #       arg.serparator <<~SERPARATOR
  #         A third line
  #         A fourth line
  #       SERPARATOR
  #     end
  #
  # Separator text can be added to any argument.
  #
  # ## Constant value
  #
  # An argument with a constant value.
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.key :limit
  #       arg.default 12345
  #     end
  #
  # This is of limited value, but it fell out of the design for free.
  #
  # ## Boolean option (switch)
  #
  # A boolean option (switch) parsed by OptParse:
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.key :quiet
  #       arg.on "-q", "--quiet", "Suppress normal output"
  #     end
  #
  # ## Value option
  # 
  # A value option parsed by OptParse:
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.key :iterations
  #       arg.default 100
  #       arg.on "-i", "--iterations=N",
  #       arg.on "Number of iterations (default _DEFAULT_)"
  #     end
  #
  # ## Required operand
  #
  # A required operand consumes one argument, with an error if there
  # isn't one to consume.
  #
  # This example overrides the help name, which is used to describe
  # the operand in the --help text.  Optional and splat arguments can
  # also have a help name override.
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.key :group
  #       arg.required_operand help_name: "resource group"
  #       arg.optional_operand
  #     end
  #
  # ## Optional operand
  #
  # An optional operand consumes one argument.  If there isn't an
  # argument to consume, then the value is either nil (if no default
  # was specified), or the specified default value.
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.key :group_name
  #       arg.default "main"
  #       arg.optional_operand
  #     end
  #
  # ## Splat Operand
  #
  # A "splat" operand consumes all remaining arguments.  Its value is
  # always an array.
  #
  #     OptParseBuilder.build_argument do |arg|
  #       arg.key :input_path
  #       arg.optional_operand
  #     end
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
