class ComposableArguments
  class ArgumentBuilder

    def initialize
      @key = nil
      @default = nil
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
      bundle = ArgumentBundle.new
      bundle << BannerArgument.new(@banner_lines) unless @banner_lines.empty?
      if @on.empty?
        if @key
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
