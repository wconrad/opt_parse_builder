module OptParseBuilder
  class OptionArgument < Argument # :nodoc:

    include HasValue

    DEFAULT_HANDLER = ->(argument, value) { argument.value = value }

    def initialize(key, default, on, handler)
      init_value(key, default)
      @on = on
      @handler = handler || DEFAULT_HANDLER
    end

    def apply_option(op)
      op.on(*edited_on) do |value|
        @handler.call(self, value)
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
