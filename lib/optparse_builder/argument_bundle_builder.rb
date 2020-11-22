class OptparseBuilder
  class ArgumentBundleBuilder

    def initialize
      @argument_bundle = ArgumentBundle.new
    end

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

    def argument
      @argument_bundle.simplify
    end

  end
end
