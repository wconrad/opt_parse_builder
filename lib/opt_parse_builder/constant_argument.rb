module OptParseBuilder
  class ConstantArgument < Argument # :nodoc:

    attr_reader :key
    attr_reader :value

    def initialize(key, value)
      unless key
        raise BuildError, "default requires a key"
      end
      @key = key
      @value = value
    end

  end
end
