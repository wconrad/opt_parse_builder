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
      op.on(*edited_on) do |v|
        @value = v
      end
    end

    def banner_lines
      []
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
