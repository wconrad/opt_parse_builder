#!/usr/bin/env ruby

require "optparse"

class Argument

  def self.check_key(key)
  end

  def self.build
    builder = Builder.new
    yield builder
    builder.argument
  end

  attr_reader :key
  attr_reader :banner_lines
  attr_reader :separator_lines
  attr_reader :value

  def initialize(
        key:,
        on: [],
        arity: nil,
        required: false,
        banner_lines: [],
        separator_lines: [],
        default: nil
      )
    if key.to_s =~ /^_/
      raise ArgumentError,
            "Argument key must not start with underscore: #{key}"
    end
    @key = key
    @on = on
    @arity = arity
    @required = required
    @banner_lines = banner_lines
    @separator_lines = separator_lines
    @default = default
    @default ||= [] if @arity
    reset
  end

  def reset
    @value = @default
  end

  def set_option(op)
    return if @on.empty?
    op.on(*@on) do |v|
      @value = v
    end
  end

  def take(argv)
    return unless @arity
    if @arity == 1
      @value = argv.shift
    else
      @value = (1..@arity).map { argv.shift }
    end
  end

  def positional?
    @arity
  end

  def required?
    positional? && @required
  end

  def positional_names
    return [] unless positional?
    (1..@arity).map do
      positional_name
    end
  end

  def positional_name
    s = @key.upcase
    s = "[#{s}]" if !required?
    s
  end

end

class Builder

  attr_reader :argument

  def initialize(
        key: nil,
        default: nil,
        on: [],
        arity: nil,
        banner: nil,
        separator: nil
      )
    @key = key
    @default = nil
    @on = on
    @arity = nil
    @required = false
    @banner_lines = [banner].compact
    @separator_lines = [separator].compact
    check
  end

  def key(v)
    @key = v
    check
  end

  def default(v)
    @default = v
    check
  end

  def on(*args)
    @on.concat(args)
    check
  end

  def positional
    @arity = 1
    required
    check
  end

  def optional
    @required = false
    check
  end

  def required
    @required = true
    check
  end

  def banner(line)
    @banner_lines << line
    check
  end

  def separator(line)
    @separator_lines << line
    check
  end

  def argument
    Argument.new(
      key: @key,
      default: @default,
      on: @on,
      arity: @arity,
      required: @required,
      banner_lines: @banner_lines,
      separator_lines: @separator_lines
    )
  end

  private

  def check
    if !@on.empty? && @arity
      raise "Argument cannot be both an option and positional"
    end
    if @required && !@arity
      raise "Only positional arguments can be required"
    end
  end
  
end

class ComposableArguments

  def initialize
    @arguments = {}
  end

  def add(*builder_args, &block)
    if builder_args.first.is_a?(Argument)
      builder_args.each do |argument|
        _add_argument(argument)
      end
    else
      if block_given?
        _add_argument(Argument.build(*builder_args, &block))
      else
        self[:add]
      end
    end
  end

  def parse!(argv)
    _reset_arguments
    op = _option_parser
    op.parse!(argv)
    @arguments.values.each do |argument|
      argument.take(argv)
    end
  end

  def has_key?(argument_key)
    @arguments.has_key?(argument_key)
  end

  def [](argument_key)
    @arguments[argument_key]&.value
  end

  def respond_to?(method)
    has_key?(method) || super
  end

  def method_missing(method)
    has_key?(method) ? self[method] : super
  end

  private

  # Prefix private methods with _ to keep them from being detected by
  # method_missing

  def _reset_arguments
    @arguments.values.each(&:reset)
  end

  def _add_argument(argument)
    @arguments[argument.key] = argument
    _check
  end

  def _option_parser
    op = OptionParser.new
    op.banner = _banner + op.banner + _positional_names
    @arguments.values.each { |arg| arg.set_option(op) }
    op.separator(_separator_lines)
    op
  end

  def _banner
    @arguments.values.map(&:banner_lines).flatten.map do |line|
      line + "\n"
    end.join
  end

  def _separator_lines
    @arguments.values.map(&:separator_lines).flatten
  end

  def _positional_names
    names = @arguments.values.map(&:positional_names).flatten
    names.empty? ? "" : " " + names.join(" ")
  end

  def _check
    optional_argument_seen = false
    @arguments.values.each do |argument|
      if argument.positional?
        if argument.required? && optional_argument_seen
          raise "Optional positional arguments must follow required ones"
        end
        optional_argument_seen ||= !argument.required?
      end
    end
  end
  
end

args = ComposableArguments.new
args.add do |arg|
  arg.banner "This is a program that does something"
  arg.separator "Some text at the bottom"
end
args.add do |arg|
  arg.banner "It has a foo"
  arg.key :foo
  arg.default false
  arg.on "-f", "--foo", "Do the foo thing"
  arg.separator "The foo does things for you"
end
args.add do |arg|
  arg.key :add
  arg.default "add"
end
Bar = Argument.build do |arg|
  arg.key :bar
  arg.positional
  arg.required
end
args.add(Bar)
args.add do |arg|
  arg.key :baz
  arg.positional
  arg.optional
end
p args.bar
args.parse!([])
p args.bar
args.parse!(["-h"])
