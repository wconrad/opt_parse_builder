class OptparseBuilder
  module FormatsOperandName

    def format_operand_name(s)
      s.to_s.gsub(/_/, " ")
    end

  end
end
