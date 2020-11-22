class ComposableArguments
  class OptionArgument < Argument

    attr_reader :key
    attr_reader :value

    def initialize(key, default, on)
      unless key
        raise BuildError, "option requires a key"
      end
      @key = key
      @default = default
      @on = on
      reset
    end

    def apply_option(op)
      op.on(*edited_on) do |v|
        @value = v
      end
    end

    def add_to_values(argument_values)
      argument_values[@key] = value
    end
      
    private

    def reset
      @value = @default
    end

    def edited_on
      @on.map do |s|
        if s.respond_to?(:gsub!)
          s.gsub(/_DEFAULT_/, @default.to_s)
        else
          s
        end
      end
    end

  end
end
