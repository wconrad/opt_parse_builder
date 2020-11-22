class ComposableArguments
  class ArgumentBundle

    def initialize
      @arguments = []
    end

    def <<(argument)
      if key && argument.key
        raise Error, "Only one argument in a bundle may have a key"
      end
      @arguments << argument
    end

    def simplify
      case @arguments.count
      when 0
        NullArgument.new
      when 1
        @arguments.first
      else
        self
      end
    end

    def key
      @arguments.each do |arg|
        return arg.key if arg.key
      end
      nil
    end

    def value
      @arguments.each do |arg|
        return arg.value if arg.value
      end
      nil
    end

    def banner_lines
      @arguments.reduce([]) do |a, arg|
        a + arg.banner_lines
      end
    end

    def apply_option(op)
      @arguments.each do |arg|
        arg.apply_option(op)
      end
    end

    def add_to_values(argument_values)
      @arguments.each do |arg|
        arg.add_to_values(argument_values)
      end
    end
       
  end
end
