class ComposableArguments
  class Option

    attr_reader :key
    attr_reader :value
    attr_reader :banner_lines

    def initialize(key, default, on, banner_lines)
      @key = key
      @default = default
      @on = on
      @banner_lines = banner_lines
      reset
    end

    def apply_option(op)
      op.on(*edited_on) do |v|
        @value = v
      end
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
