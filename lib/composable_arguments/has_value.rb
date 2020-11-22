class ComposableArguments
  module HasValue

    attr_reader :key
    attr_reader :value

    def init_value(key, default)
      unless key
        raise BuildError, "argument with value requires a key"
      end
      @key = key
      @default = default
      reset
    end

    def reset
      @value = @default
    end
    
  end
end
