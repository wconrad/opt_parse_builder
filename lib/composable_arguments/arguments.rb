module ComposableArguments

  class Arguments

    def parse!(argv)
      begin
        op = OptParse.new
        op.parse!(argv)
        unless argv.empty?
          raise OptionParser::NeedlessArgument, argv.first
        end
      rescue OptionParser::ParseError => e
        abort e.message
      end
    end
    
  end

end
