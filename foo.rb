#!/usr/bin/env ruby

require "optparse"

class ComposableArguments

  def initialize
    @args = []
  end

  def add(arg)
    @args << arg
    arg.define_accessor(self)
  end

  def parse!(argv)
    op = option_parser
    op.parse!(argv)
    @args.each do |arg|
      arg.apply_to_argv(argv)
    end
  end

  private

  def option_parser
    op = OptionParser.new
    op.banner = help_intro + op.banner
    @args.each do |arg|
      arg.set_option(op)
      if arg.help_extro
        op.separator(arg.help_extro)
      end
    end
    op
  end

  def help_intro
    @args.map do |arg|
      add_nl(arg.help_intro)
    end.compact.join
  end

  def add_nl(s)
    s && s + "\n"
  end
  
end

class ComposableArgument

  def set_option_reverse(op)
  end

  def set_option(op)
  end

  def apply_to_argv(argv)
  end

  def define_accessor(args)
  end

  def help_intro
  end

  def help_extro
  end
  
end

class TopText < ComposableArgument

  def initialize(text)
    @text = text
  end

  def help_intro
    @text
  end

end

class BottomText < ComposableArgument

  def initialize(text)
    @text = text
  end

  def help_extro
    @text
  end

end

module HasValue

  def initialize(name, default: nil)
    @name = name
    @default = default
    reset
  end

  def default=(v)
    @default = default
    reset
  end

  def define_accessor(args)
    arg = self
    args.define_singleton_method(@name) do
      arg.instance_eval { @value }
    end
  end

  def reset
    @value = @default
  end
  
end

class PositionalArgument < ComposableArgument

  include HasValue

  def apply_to_argv(argv)
    @value = argv.shift
  end

end

class Option < ComposableArgument

  include HasValue

  def self.new(*args)
    if block_given?
      switch = super
      yield(switch)
      switch
    else
      super
    end
  end

  def initialize(name, default: nil)
    super
    @op_args = []
  end

  def on(*args)
    @op_args += args
  end

  def set_option(op)
    op.on(*@op_args) do |v|
      @value = v
    end
  end

end

class BooleanOption < Option

  def initialize(*args)
    super(*args, default: false)
  end
  
end

args = ComposableArguments.new
args.add(TopText.new("This is a program"))
args.add(TopText.new("It does things"))
args.add(BottomText.new("Text at the bottom"))
args.add(BottomText.new("More text at the bottom"))
args.add(BooleanOption.new(:dry_run) do |sw|
           sw.on("-d", "--dry-run", "Dry run (make no changes)")
         end)
args.add(PositionalArgument.new(:foo))
# args.parse!(["--dry-run", "1"])
# p args.foo
# p args.dry_run
args.parse!(["-h"])
