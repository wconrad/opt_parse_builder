class OptparseBuilder

  # The base class for all exceptions directly raised by this library.
  Error = Class.new(StandardError)

  # A build error has happened when using DSL to build a parser,
  # argument, or argument bundle.
  BuildError = Class.new(Error)

end
