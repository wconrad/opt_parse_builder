require "optparse"

require_relative "stable_sort"

module OptParseBuilder

  # A command-line parser.  Create an instance of this by calling
  # OptParseBuilder.build_parser.
  #
  # Note: The constructor for this class is not part of the public
  # API.
  class Parser

    include StableSort

    # Controls whether unparsed arguments are an error.
    #
    # If `false` (the default), then unparsed arguments cause an
    # error:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.allow_unparsed_operands = false
    #       args.add do |arg|
    #         arg.key :quiet
    #         arg.on "-q", "--quiet", "Suppress normal output"
    #       end
    #     end
    #
    #     ARGV = ["-q", "/tmp/file1", "/tmp/file2"]
    #     arg_values = arg_parser.parse!
    #     # aborts with "needless argument: /tmp/file1"
    #
    # If `true`, then unparsed operands are not considered an error, and
    # they remain unconsumed.  Use this setting when you want unparsed
    # operands to remain in `ARGV` so that they can be used by, for
    # example, `ARGF`:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.allow_unparsed_operands = true
    #       args.add do |arg|
    #         arg.key :quiet
    #         arg.on "-q", "--quiet", "Suppress normal output"
    #       end
    #     end
    #
    #     ARGV = ["-q", "/tmp/file1", "/tmp/file2"]
    #     arg_values = arg_parser.parse!
    #     # ARGV now equals ["/tmp/file1", "/tmp/file2"]
    #     ARGF.each_line do |line|
    #       puts line unless arg_values.quiet
    #     end
    attr_accessor :allow_unparsed_operands

    def initialize # :nodoc:
      @arguments = []
      @allow_unparsed_operands = false
    end

    # Reset to the state after construction, before #parse! was called.
    # Each argument is set to its default value.  An argument with no
    # explicit default is set to `nil`.
    #
    # This is called implicitly when you call #parse!, so there's seldom
    # any need for it to be called explicitly.
    def reset
      @arguments.each(&:reset)
      sort_arguments
    end

    # Parse arguments, consuming them from the array.
    #
    # After parsing, there are numerous ways to access the value of the arguments:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.add do |arg|
    #         arg.key :num
    #         arg.on "--num=N", Integer, "A number"
    #       end
    #     end
    #     arg_values = arg_parser.parse!(["--num=123"])
    #     p arg_parser[:num]     # => 123
    #     p arg_parser["num"]    # => 123
    #     p arg_values[:num]     # => 123
    #     p arg_values["num"]    # => 123
    #     p arg_values.num       # => 123
    #
    # If there are operands (positional arguments) in the array that are
    # not consumed, an error normally results.  This behavior can be
    # changed using #allow_unparsed_operands.
    #
    # The #parse! method defaults to parsing `ARGV`, which is what is
    # usually wanted, but you can pass in any array of strings, as the
    # above example does.
    #
    # Design note: A method that modifies its argument _and_ modifies
    # its object _and_ returns a value is not the best design, violating
    # the good principle of command-query separation.  However, that
    # violation is more useful in this case than it is sinful, and it's
    # the only place in this library that violates that principle.
    def parse!(argv = ARGV)
      reset
      begin
        op = optparse
        op.parse!(argv)
        @arguments.each do |arg|
          arg.shift_operand(argv)
        end
        unless @allow_unparsed_operands || argv.empty?
          raise OptionParser::NeedlessArgument, argv.first
        end
        values
      rescue OptionParser::ParseError => e
        abort e.message
      end
    end

    # Add a line to the banner.  The banner is text that appears at the
    # top of the help text.
    #
    # A new-line will automatically be added to the end of the line.
    # Although it's called a "line," you can embed new-lines in it so
    # that it is actually more than one line.
    #
    # This example:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.banner "This is my program"
    #       args.banner <<~BANNER
    #         There are many programs like it,
    #         but this program is mine.
    #       BANNER
    #     end
    #     arg_parser.parse!(["--help"])
    #
    # Results in `--help` output like this:
    #
    #     This is my program
    #     There are many programs like it,
    #     but this program is mine.
    #     Usage: example [options] <path>
    def banner(line)
      add do |arg|
        arg.banner(line)
      end
    end

    # Add a line to the separator.  The separator is text that appears
    # at the bottom of the help text.
    #
    # A new-line will automatically be added to the end of the line.
    # Although it's called a "line," you can embed new-lines in it so
    # that it is actually more than one line.
    #
    # This example:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.separator "Here I explain more about my program"
    #       args.separator <<~SEPARATOR
    #         For such a small program,
    #         it has a lot of text at the end.
    #       SEPARATOR
    #     end
    #     arg_parser.parse!(["--help"])
    #
    # Results in `--help` output like this:
    #
    #     Usage: example [options] <path>
    #     Here I explain more about my program
    #     For such a small program,
    #     it has a lot of text at the end.
    def separator(line)
      add do |arg|
        arg.separator(line)
      end
    end

    # Add an argument.  Must be passed either the argument to add, or
    # given a block.  If given a block, yields an ArgumentBuilder.
    #
    # Example using a pre-built argument:
    #
    #     DRY_RUN = OptParseBuilder.build_argument do |arg|
    #       arg.key :dry_run
    #       arg.on "-d", "--dry-run", "Make no changes"
    #     end
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.add DRY_RUN
    #     end
    #
    # Example using a block to build the argument in-place:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.add do |arg|
    #         arg.key :dry_run
    #         arg.on "-d", "--dry-run", "Make no changes"
    #       end
    #     end
    #
    # This is equivalent to:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.add OptParseBuilder.build_argument do |arg|
    #         arg.key :dry_run
    #         arg.on "-d", "--dry-run", "Make no changes"
    #       end
    #     end
    #
    # See the README for details of the different options available
    # for an argument.
    #
    # Raises BuildError if the argument cannot be built or added.
    def add(argument = nil, &block)
      unless argument.nil? ^ block.nil?
        raise BuildError, "Need exactly 1 of arg and block"
      end
      if argument
        add_argument(argument)
      else
        add_argument(OptParseBuilder.build_argument(&block))
      end
    end

    # Returns the value of an argument, given either a symbol or a
    # string with its name.  If the key does not exist, raises KeyError.
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.add do |arg|
    #         arg.key :x
    #         arg.default 123
    #       end
    #     end
    #     arg_parser[:x]     # => 123
    #     arg_parser["x"]    # => 123
    #     arg_parser[:y]     # KeyError (key not found :y)
    #
    # See also:
    #
    #   * method #values - returns a collection of all argument values
    #   * method #has_key? - find out if the parser knows about a key
    def [](key)
      find_argument!(key).value
    end

    # Return a collection with all of the argument values.  The
    # collection can be accessed in several ways:
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.add do |arg|
    #         arg.key :num
    #         arg.on "--num=N", Integer, "A number"
    #       end
    #     end
    #     arg_parser.parse!(["--num=123"])
    #     arg_values = arg_parser.values
    #     p arg_values[:num]     # => 123
    #     p arg_values["num"]    # => 123
    #     p arg_values.num       # => 123
    def values
      av = ArgumentValues.new
      @arguments.each do |arg|
        av[arg.key] = arg.value if arg.key
      end
      av
    end

    # Return true if the parser has the named key, which may be either a
    # string or a symbol.
    #
    #     arg_parser = OptParseBuilder.build_parser do |args|
    #       args.add do |arg|
    #         arg.key :quiet
    #       end
    #     end
    #     arg_parser.has_key?(:quiet)      # => true
    #     arg_parser.has_key?("quiet")     # => true
    #     arg_parser.has_key?(:verbose)    # => false
    def has_key?(key)
      !!find_argument(key)
    end

    private

    def sort_arguments
      stable_sort_by!(@arguments) do |arg|
        case arg
        when RequiredOperandArgument
          1
        when OptionalOperandArgument
          2
        when SplatOperandArgument
          3
        else
          0
        end
      end
    end

    def find_argument!(key)
      argument = find_argument(key)
      unless argument
        raise Key, "key not found #{key.inspect}"
      end
      argument
    end

    def find_argument(key)
      key = key.to_sym
      @arguments.find do |arg|
        arg.key == key
      end
    end

    def optparse
      op = OptParse.new
      op.banner = banner_prefix + op.banner + banner_suffix
      @arguments.each { |arg| arg.apply_option(op) }
      @arguments.each do |argument|
        argument.separator_lines.each do |line|
          op.separator(line)
        end
      end
      op
    end

    def add_argument(argument)
      if argument.key && has_key?(argument.key)
        raise BuildError, "duplicate key #{argument.key}"
      end
      @arguments.concat(argument.to_a.map(&:dup))
    end

    def banner_prefix
      @arguments.flat_map(&:banner_lines).map do |line|
        line + "\n"
      end.join
    end

    def banner_suffix
      suffix = @arguments.map(&:operand_notation).compact.join(" ")
      suffix = " " + suffix unless suffix.empty?
      suffix
    end

  end
end
