module OptParseBuilder
  module FormatsOperandName # :nodoc:

    def format_operand_name(s)
      s.to_s.gsub(/_/, " ")
    end

  end
end
