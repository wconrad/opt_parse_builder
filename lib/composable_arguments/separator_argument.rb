class ComposableArguments
  class SeparatorArgument < Argument

    attr_reader :separator_lines

    def initialize(separator_lines)
      @separator_lines = separator_lines
    end

  end
end
