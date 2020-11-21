require_relative "composable_arguments/argument_builder"
require_relative "composable_arguments/option"

class ComposableArguments

  def self.build_argument
    builder = ArgumentBuilder.new
    yield builder
    builder.argument
  end

  def initialize
    @arguments = {}
  end

  def parse!(argv)
    begin
      op = _optparse
      op.parse!(argv)
      unless argv.empty?
        raise OptionParser::NeedlessArgument, argv.first
      end
    rescue OptionParser::ParseError => e
      abort e.message
    end
  end

  def add(arg = nil, &block)
    if !arg && !block
      self[:add]
    elsif arg
      _add_argument(arg)
    else
      _add_argument(self.class.build_argument(&block))
    end
  end

  def [](key)
    @arguments.fetch(key).value
  end

  def method_missing(name)
    super unless @arguments.has_key?(name)
    @arguments[name].value
  end

  private

  # Prefix private methods with _ to keep them from being detected by
  # method_missing, in the unexpected case that someone creases an
  # argument with a key :optparse (for example).

  def _optparse
    op = OptParse.new
    @arguments.values.each { |arg| arg.apply_option(op) }
    op
  end

  def _add_argument(argument)
    @arguments[argument.key] = argument
  end

end
