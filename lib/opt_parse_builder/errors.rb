module OptParseBuilder

  # The base class for all exceptions directly raised by this library.
  class Error < StandardError ; end

  # Exception raised for an error when building a parser, argument or
  # argument bundle.
  class BuildError < Error ; end

end
