class ComposableArguments
  class Option

    attr_reader :key
    attr_reader :value

    def initialize(key, default, on)
      @key = key
      @on = on
      @default = default
      reset
    end

    def apply_option(op)
      op.on(*@on) do |v|
        @value = v
      end
    end

    private

    def reset
      @value = @default
    end
    
  end
end
