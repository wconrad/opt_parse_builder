module OptParseBuilder

  # The base class for all arguments.  You don't create arguments
  # explicitly; they are created by for you when you use the builder
  # API.
  class Argument

    def key # :nodoc:
    end

    # Get an argument's value.  Returns nil if the argument has no
    # value.  This is made public for the use of a handler proc (See
    # ArgumentBuilder#handler).
    def value
    end

    # Set the argument's value.  Does nothing if the argument has no
    # value.  This is made public for the use of a handler proc (See
    # ArgumentBuilder#handler).
    def value=(_v)
    end

    def banner_lines # :nodoc:
      []
    end

    def operand_notation # :nodoc:
    end

    def separator_lines # :nodoc:
      []
    end

    def footer_lines # :nodoc:
      []
    end

    def apply_option(_op) # :nodoc:
    end

    def shift_operand(_argv) # :nodoc:
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
