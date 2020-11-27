require "forwardable"

module OptParseBuilder
  class ParserBuilder

    extend Forwardable

    attr_reader :parser

    def initialize
      @parser = Parser.new
    end

    def_delegators :@parser,  :add, :banner, :separator

  end
end
