module OptParseBuilder

  # The base class for all arguments.  You don't create arguments
  # explicitly; they are created by for you when you use the builder
  # API.
  class Argument

    def key # :nodoc:
    end

    def value # :nodoc:
    end

    def banner_lines # :nodoc:
      []
    end

    def operand_notation # :nodoc:
    end

    def separator_lines # :nodoc:
      []
    end

    def apply_option(op) # :nodoc:
    end

    def shift_operand(argv) # :nodoc:
    end

    def reset # :nodoc:
    end

    def to_a # :nodoc:
      [self]
    end

    # Convert from a required operand to an optional one, returning a
    # new argument.  Raises an error if that isn't possible.
    def optional
      raise BuildError,
            "cannot convert #{self.class.name} to an optional operand"
    end

    # Convert from a required operand to an optional one, returning a
    # new argument.  Raises an error if that isn't possible.
    def required
      raise BuildError,
            "cannot convert #{self.class.name} to a required operand"
    end
       
  end
end
