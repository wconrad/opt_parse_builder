module ComposableArguments

  class Arguments

    def parse!(argv)
      op = OptParse.new
      op.parse!(argv)
    end
    
  end

end
