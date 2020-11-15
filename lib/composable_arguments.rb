require_relative "composable_arguments/argument_builder"
require_relative "composable_arguments/option"

class ComposableArguments

  def initialize
    @arguments = {}
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

  def add
    builder = ArgumentBuilder.new
    yield builder
    add_argument builder.argument
  end

  def [](key)
    @arguments.fetch(key).value
  end

  private

  def optparse
    op = OptParse.new
    @arguments.values.each { |arg| arg.apply_option(op) }
    op
  end

  def add_argument(argument)
    @arguments[argument.key] = argument
  end

end
