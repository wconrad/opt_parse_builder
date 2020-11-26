module OptParseBuilder
  class BannerArgument < Argument # :nodoc:

    attr_reader :banner_lines

    def initialize(banner_lines)
      @banner_lines = banner_lines
    end

  end
end
