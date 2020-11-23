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

  def self.build_argument
    builder = ArgumentBuilder.new
    yield builder
    builder.argument
  end

  def self.build_bundle
    bundler = ArgumentBundleBuilder.new
    yield bundler
    bundler.argument
  end

  attr_accessor :allow_unparsed_operands

  def initialize
    @arguments = []
    @allow_unparsed_operands = false
    yield self if block_given?
  end

  def reset
    @arguments.each(&:reset)
    sort_arguments
  end

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
