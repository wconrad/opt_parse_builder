class ComposableArguments
  class ArgumentBuilder

    def initialize
      @key = nil
      @defualt = nil
      @on = []
    end

    def key(v)
      @key = v
    end

    def default(v)
      @default = v
    end

    def on(*option_args)
      @on.concat(option_args)
    end

    def argument
      if @on.empty?
        Constant.new(@key, @default)
      else
        Option.new(@key, @default, @on)
      end
    end

  end
end
