class OptparseBuilder

  # The base class for all exceptions directly raised by this library.
  Error = Class.new(StandardError)

  # Exception raised for an error when building a parser, argument or
  # argument bundle.
  BuildError = Class.new(Error)

end
