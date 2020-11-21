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
      if @on.empty?
        if @key
          Constant.new(@key, @default, @banner_lines)
        elsif !@banner_lines.empty?
          BannerArgument.new(@banner_lines)
        else
          NullArgument.new
        end
      else
        Option.new(@key, @default, @on, @banner_lines)
      end
    end

  end
end
