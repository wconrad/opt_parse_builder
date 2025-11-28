module OptParseBuilder
  class FooterArgument < Argument # :nodoc:

    attr_reader :footer_lines

    def initialize(footer_lines)
      @footer_lines = footer_lines
    end

  end
end
