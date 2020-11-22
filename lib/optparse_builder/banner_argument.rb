class OptparseBuilder
  class BannerArgument < Argument

    attr_reader :banner_lines

    def initialize(banner_lines)
      @banner_lines = banner_lines
    end

  end
end
