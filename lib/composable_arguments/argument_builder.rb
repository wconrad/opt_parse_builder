class ComposableArguments
  class ArgumentBuilder

    def initialize
      @key = nil
      @default = nil
      @on = []
      @banner_lines = []
      @separator_lines = []
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

    def separator(line)
      @separator_lines << line
    end

    def argument
      bundle = ArgumentBundle.new
      unless @banner_lines.empty?
        bundle << BannerArgument.new(@banner_lines)
      end
      unless @separator_lines.empty?
        bundle << SeparatorArgument.new(@separator_lines)
      end
      if @on.empty?
        if @key || @default
          bundle << ConstantArgument.new(@key, @default)
        else
          bundle << NullArgument.new
        end
      else
        bundle << OptionArgument.new(@key, @default, @on)
      end
      bundle.simplify
    end

  end
end
