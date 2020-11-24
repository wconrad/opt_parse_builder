class OptparseBuilder

  # Builds arguments using a builder style DSL.  You never create an
  # instance of this class yourself.  Instead, an instance is yielded
  # to you by OptparseBuilder.
  #
  # # Types of arguments, by example
  #
  # A null argument, having no value or visible effect:
  #
  #     OptparseBuilder.build_argument do |arg|
  #     end
  #
  # An argument with only banner text (but see OptparseBuilder#banner
  # for the usual way to do this).  "Banner" is how OptParse describes
  # text that appears at the top of the --help output.
  #
  #     OptparseBuilder.build_argument do |arg|
  #       arg.banner "Some banner text"
  #       arg.banner "A second line of banner text"
  #       arg.banner <<~BANNER
  #         A third line
  #         A fourth line
  #       BANNER
  #     end
  #
  # An argument with only separator text (but see
  # OptparseBuilder#banner for the usual way to do this).  "Separator"
  # is how OptParse describes text that appears at the bottom of the
  # --help output.
  #
  #     OptparseBuilder.build_argument do |arg|
  #       arg.serparator "Separator text"
  #       arg.serparator "A second line of separator text"
  #       arg.serparator <<~SERPARATOR
  #         A third line
  #         A fourth line
  #       SERPARATOR
  #     end
  #
  # An argument with a constant value.  Perhaps of limited value, but
  # it fell out of the design for free, so here it is:
  #
  #     OptparseBuilder.build_argument do |arg|
  #       arg.key :limit
  #       arg.default 12345
  #     end
  #
  # A boolean option (switch) handled by OptParse:
  #
  #     OptparseBuilder.build_argument do |arg|
  #       arg.key :quiet
  #       arg.on "-q", "--quiet", "Suppress normal output"
  #     end
  #
  #
  # ## Value option
  # 
  # A value option is parsed by OptParse:
  #
  #     OptparseBuilder.build_argument do |arg|
  #       arg.key :iterations
  #       arg.default 100
  #       arg.on "-i", "--iteraions=N",
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
  #     OptparseBuilder.build_argument do |arg|
  #       arg.key :group
  #       arg.required_operand help_name: "resource group"
  #       arg.optional_operand
  #     end
  #
  # The --help output for this argument looks like this:
  #
  #     myprogram [options] <resource group>
  #
  # ## Optional operand
  #
  # An optional operand consumes one argument.  If there isn't an
  # argument to consume, then the value is either the default (if
  # specified), or nil (if no default was specified).
  #
  #     OptparseBuilder.build_argument do |arg|
  #       arg.key :group_name
  #       arg.optional_operand
  #     end
  #
  # The --help output for this argument looks like this:
  #
  #     myprogram [options] [<resource group>]
  #
  # ## Splat Operand
  #
  # A "splat" operand consumes all remaining arguments.  Its value is
  # always an array.
  #
  #     OptparseBuilder.build_argument do |arg|
  #       arg.key :input_path
  #       arg.optional_operand
  #     end
  #
  # The --help output for this argument looks like this:
  #
  #     myprogram [options] [<input path>...]
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

    # Set the argument's key to either a String or a Symbol.  Used
    # for:
    #
    # * Retrieving the argument's value
    # * Forming the default "help string" of an operand
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
    #
    # Simple example:
    #
    #     arg = OptparseBuilder.build_argument do |arg|
    #       arg.key :quiet
    #       arg.on "-q", "Be very veru quiet", "We're hunting rabbit!"
    #     end
    #
    # You may split up a long argument list by calling this method
    # more than once.  This is equivalent to the above:
    #
    #     arg = OptparseBuilder.build_argument do |arg|
    #       arg.key :quiet
    #       arg.on "-q", "Be very veru quiet",
    #       arg.on "We're hunting rabbit!"
    #     end
    #
    # So that the option's help may print the default without having
    # to duplicate it, the string _DEFAULT_ is replaced with the
    # argument's default value:
    #
    #     arg = OptparseBuilder.build_argument do |arg|
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
    # Any type of argument may have banner text:
    #
    #     arg = OptparseBuilder.build_argument do |arg|
    #       arg.banner "PATH is so important that"
    #       arg.banner "we must tell you about it first!"
    #       arg.key :path
    #       arg.required_operand
    #     end
    #
    # You can also have banner text on its own:
    #
    #     arg = OptparseBuilder.build_argument do |arg|
    #       arg.banner "Some banner text"
    #     end
    #
    # This is useful when you have some banner text that is shared
    # among multiple programs.
    #
    # But most of the time you probably want to use
    # OptparseBuilder#banner
    def banner(line)
      @banner_lines << line
    end

    # Add to the separator text shown last in the --help output.  You
    # may call this more than once; each call adds another line of
    # text to the separator.
    #
    # Any type of argument may have separator text:
    #
    #     arg = OptparseBuilder.build_argument do |arg|
    #       arg.key :path
    #       arg.required_operand
    #       arg.separator "<path> must be the path of a UTF-8 or"
    #       arg.separator "       UTF-16 file"
    #     end
    #
    # You can also have separator text on its own:
    #
    #     arg = OptparseBuilder.build_argument do |arg|
    #       arg.separator "Some separator text"
    #     end
    #
    # This is useful when you have some separator text that is shared
    # among multiple programs.
    #
    # But most of the time you probably want to use
    # OptparseBuilder#separator
    def separator(line)
      @separator_lines << line
    end

    def optional_operand(help_name: nil)
      check_operand_class_not_set
      @operand_class = OptionalOperandArgument
      @operand_help_name = help_name
    end

    def required_operand(help_name: nil)
      check_operand_class_not_set
      @operand_class = RequiredOperandArgument
      @operand_help_name = help_name
    end

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
