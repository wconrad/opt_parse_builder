class ComposableArguments
  class Constant

    attr_reader :key
    attr_reader :value
    attr_reader :banner_lines

    def initialize(key, value, banner_lines)
      @key = key
      @value = value
      @banner_lines = banner_lines
    end

    def apply_option(op)
    end
    
  end
end
