require_relative "composable_arguments/argument"
require_relative "composable_arguments/argument_builder"
require_relative "composable_arguments/argument_bundle"
require_relative "composable_arguments/argument_bundle_builder"
require_relative "composable_arguments/argument_values"
require_relative "composable_arguments/banner_argument"
require_relative "composable_arguments/constant_argument"
require_relative "composable_arguments/errors"
require_relative "composable_arguments/null_argument"
require_relative "composable_arguments/optional_operand_argument"
require_relative "composable_arguments/option_argument"
require_relative "composable_arguments/separator_argument"

class ComposableArguments

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

  def initialize
    @arguments = []
  end

  def reset
    @arguments.each(&:reset)
  end

  def parse!(argv)
    reset
    begin
      op = optparse
      op.parse!(argv)
      @arguments.each do |arg|
        arg.shift_operand(argv)
      end
      unless argv.empty?
        raise OptionParser::NeedlessArgument, argv.first
      end
    rescue OptionParser::ParseError => e
      abort e.message
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
      arg.add_to_values(av)
    end
    av
  end

  private

  def has_key?(key)
    !!find_argument(key)
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
    @arguments << argument
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
