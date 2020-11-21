class ComposableArguments
  class ArgumentBuilder

    def initialize
      @key = nil
      @defualt = nil
      @on = []
      @banner_lines = []
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

    def banner(line)
      @banner_lines << line
    end

    def argument
      if @on.empty?
        Constant.new(@key, @default, @banner_lines)
      else
        Option.new(@key, @default, @on, @banner_lines)
      end
    end

  end
end
