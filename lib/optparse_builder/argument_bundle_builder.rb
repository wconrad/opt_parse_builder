class OptparseBuilder

  # Yielded by OptparseBuilder.bundle_arguments to create an
  # ArgumentBundle, a collection of arguments that can be treated as
  # through it is one argument.
  class ArgumentBundleBuilder

    def initialize # :nodoc:
      @argument_bundle = ArgumentBundle.new
    end

    # Add an argument to the bundle.  Takes either the argument to
    # add, or yields an ArgumentBuilder which builds a new argument
    # and adds it.
    #
    # If adding an existing argument, that argument may itself be an
    # ArgumentBundle.
    def add(argument = nil, &block)
      unless argument.nil? ^ block.nil?
        raise BuildError, "Need exactly 1 of arg and block"
      end
      if argument
        @argument_bundle << argument
      else
        @argument_bundle << OptparseBuilder.build_argument(&block)
      end
    end

    def argument # :nodoc:
      @argument_bundle.simplify
    end

  end
end
