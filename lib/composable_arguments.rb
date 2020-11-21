require_relative "composable_arguments/argument_builder"
require_relative "composable_arguments/argument_values"
require_relative "composable_arguments/banner_argument"
require_relative "composable_arguments/constant"
require_relative "composable_arguments/null_argument"
require_relative "composable_arguments/option"

class ComposableArguments

  def self.build_argument
    builder = ArgumentBuilder.new
    yield builder
    builder.argument
  end

  def initialize
    @arguments = []
    @keys = {}
  end

  def parse!(argv)
    begin
      op = optparse
      op.parse!(argv)
      unless argv.empty?
        raise OptionParser::NeedlessArgument, argv.first
      end
    rescue OptionParser::ParseError => e
      abort e.message
    end
  end

  def add(arg = nil, &block)
    if arg
      add_argument(arg)
    else
      add_argument(self.class.build_argument(&block))
    end
  end

  def [](key)
    @keys.fetch(key.to_sym).value
  end

  def values
    r = ArgumentValues.new
    @keys.each do |key, arg|
      r[key] = arg.value
    end
    r
  end

  private

  def optparse
    op = OptParse.new
    op.banner = banner_prefix + op.banner
    @arguments.each { |arg| arg.apply_option(op) }
    op
  end

  def add_argument(argument)
    @arguments << argument
    if argument.respond_to?(:key)
      @keys[argument.key] = argument
    end
  end

  def banner_prefix
    @arguments.map(&:banner_lines).flatten.map do |line|
      line + "\n"
    end.join
  end

end
