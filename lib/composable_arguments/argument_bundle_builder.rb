class ComposableArguments
  class ArgumentBundleBuilder

    def initialize
      @argument_bundle = ArgumentBundle.new
    end

    def add(&block)
      @argument_bundle << ComposableArguments.build_argument(&block)
    end

    def argument
      @argument_bundle.simplify
    end

  end
end
