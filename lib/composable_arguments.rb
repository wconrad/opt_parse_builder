class ComposableArguments

  def initialize
    @arguments = {}
  end

  def parse!(argv)
    begin
      op = optparse
      op.parse!(argv)
      unless argv.empty?
        raise OptionParser::NeedlessArgument, argv.first
      end
    rescue OptionParser::ParseError => e
      abort e.message
    end
  end

  private

  def optparse
    op = OptParse.new
    op
  end

end
