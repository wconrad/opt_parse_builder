class OptparseBuilder
  class OptionArgument < Argument

    include HasValue

    def initialize(key, default, on)
      init_value(key, default)
      @on = on
    end

    def apply_option(op)
      op.on(*edited_on) do |v|
        @value = v
      end
    end

    private

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
