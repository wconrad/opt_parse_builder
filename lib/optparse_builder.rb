require "optparse"

require_relative "optparse_builder/argument"
require_relative "optparse_builder/argument_builder"
require_relative "optparse_builder/argument_bundle"
require_relative "optparse_builder/argument_bundle_builder"
require_relative "optparse_builder/argument_values"
require_relative "optparse_builder/banner_argument"
require_relative "optparse_builder/constant_argument"
require_relative "optparse_builder/errors"
require_relative "optparse_builder/formats_operand_name"
require_relative "optparse_builder/has_value"
require_relative "optparse_builder/null_argument"
require_relative "optparse_builder/option_argument"
require_relative "optparse_builder/optional_operand_argument"
require_relative "optparse_builder/required_operand_argument"
require_relative "optparse_builder/separator_argument"
require_relative "optparse_builder/splat_operand_argument"
require_relative "optparse_builder/stable_sort"

class OptparseBuilder

  include StableSort

  # Build an argument that can be added to a parser.  Yields an
  # ArgumentBuilder.
  #
  #     VERBOSE = OptparseBuilder.build_argument do |arg|
  #       arg.key :verbose
  #       arg.on "-v", "--verbose", "Print extra output"
  #     end
  #
  #     parser = OptparseBuilder.new do |args|
  #       args.add VERBOSE
  #     end
  #
  # This is most useful when you are building a related suite of
  # programs that share some command-line arguments in common.  Most
  # of the time you will just add the argument using the block form of
  # OptparseBuilder#add.
  
  def self.build_argument
    builder = ArgumentBuilder.new
    yield builder
    builder.argument
  end

  # Build a bundle of arguments that can be added to a parser
  # together.  Yields an ArgumentBundleBuilder.
  #
  # This is useful when you have a group of arguments that go
  # together:
  #
  #     bundle = OptparseBuilder.build_bundle do |args|
  #       args.add do |arg|
  #         arg.key :x
  #         op.on "-x", Integer, "X coordinate"
  #       end
  #       args.add do |arg|
  #         arg.key :y
  #         op.on "-y", Integer, "Y coordinate"
  #       end
  #     end
  #
  #     parser = OptparseBuilder.new do |args|
  #       args.add bundle
  #     end
  #
  # This is most useful when you are building a related suite of
  # programs that share some command-line arguments in common.  Most
  # of the time you will just add the arguments using the block form
  # of OptparseBuilder#add.
  def self.build_bundle
    bundler = ArgumentBundleBuilder.new
    yield bundler
    bundler.argument
  end

  # Controls whether unparsed arguments are an error.
  #
  # If `false` (the default), then unparsed arguments cause an
  # error:
  #
  #     parser = OptparseBuilder.new do |args|
  #       args.allow_unparsed_operands = false
  #       args.add do |arg|
  #         arg.key :quiet
  #         arg.on "-q", "--quiet", "Suppress normal output"
  #       end
  #     end
  #
  #     ARGV = ["-q", "/tmp/file1", "/tmp/file2"]
  #     arg_values = parser.parse!
  #     # aborts with "needless argument: /tmp/file1"
  #
  # If `true`, then unparsed operands are not considered an error, and
  # they remain unconsumed.  Use this setting when you need for
  # unparsed operands to remain in `ARGV` so that they can be used by,
  # for example, `ARGF`:
  #
  #     parser = OptparseBuilder.new do |args|
  #       args.allow_unparsed_operands = true
  #       args.add do |arg|
  #         arg.key :quiet
  #         arg.on "-q", "--quiet", "Suppress normal output"
  #       end
  #     end
  #
  #     ARGV = ["-q", "/tmp/file1", "/tmp/file2"]
  #     arg_values = parser.parse!
  #     # ARGV now equals ["/tmp/file1", "/tmp/file2"]
  #     ARGF.each_line do |line|
  #       puts line unless arg_values.quiet
  #     end
  attr_accessor :allow_unparsed_operands

  # Create a new parser.  If called without a block, returns a parser
  # than you can then add arguments to:
  #
  #     parser = OptparseBuilder.new
  #     parser.add do |arg|
  #       arg.key :force
  #       arg.on "--force", "Force dangerous operation"
  #     end
  #
  # If called with a block, yields itself to the block:
  #
  #     parser = OptparseBuilder.new do |args|
  #       arg.key :force
  #       arg.on "--force", "Force dangerous operation"
  #     end
  #
  # Note that the parser constructed using the block form can still
  # be added onto:
  #
  #     parser.add do |arg|
  #       arg.key :size
  #       arg.on "--size=N", Integer, "File size in bytes"
  #     end
  #    
  def initialize
    @arguments = []
    @allow_unparsed_operands = false
    yield self if block_given?
  end

  # Reset to the state after construction, before #parse! was called.
  # Each argument is set to its default value.  An argument with no
  # explicit default is set to `nil`.
  def reset
    @arguments.each(&:reset)
    sort_arguments
  end

  # Parse arguments.  Consumes arguments from the array as they are
  # parsed.
  #
  # After parsing, you can get the argument values in either of two
  # ways:
  #
  # * Use #[] to fetch the values directly from the parser.
  # * Use #values to return a collection of argument values.
  #
  # If there are operands (positional arguments) in the array that are
  # not consumed, an error normally results.  This behavior can be
  # changed using #allow_unparsed_operands.
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

  def banner(line)
    self.add do |arg|
      arg.banner(line)
    end
  end

  def separator(line)
    self.add do |arg|
      arg.separator(line)
    end
  end

  def add(argument = nil, &block)
    unless argument.nil? ^ block.nil?
      raise BuildError, "Need exactly 1 of arg and block"
    end
    if argument
      add_argument(argument)
    else
      add_argument(self.class.build_argument(&block))
    end
  end

  def [](key)
    find_argument!(key).value
  end

  def values
    av = ArgumentValues.new
    @arguments.each do |arg|
      av[arg.key] = arg.value if arg.key
    end
    av
  end

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
      raise ArgumentError, "No such argument: #{key}"
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
    @arguments.map(&:banner_lines).flatten.map do |line|
      line + "\n"
    end.join
  end

  def banner_suffix
    suffix = @arguments.map(&:operand_notation).compact.join(" ")
    suffix = " " + suffix unless suffix.empty?
    suffix
  end

end
