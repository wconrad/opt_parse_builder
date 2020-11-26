class OptParseBuilder
  class ArgumentBundle < Argument # :nodoc:

    def initialize
      @arguments = []
    end

    def <<(argument)
      @arguments << argument
    end

    def to_a
      @arguments.reduce([]) do |a, arg|
        a + arg.to_a
      end
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

  end
end
