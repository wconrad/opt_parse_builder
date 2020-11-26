#!/usr/bin/env ruby

require "opt_parse_builder"

ARG_PARSER = OptParseBuilder.build_parser do |parser|
  parser.banner "A simple example"
  parser.add do |arg|
    arg.key :path
    arg.required_operand
  end
  parser.add do |arg|
    arg.key :verbose
    arg.on "-v", "--verbose", "Be verbose"
  end
  parser.separator "Some explanatory text at the bottom"
end

arg_values = ARG_PARSER.parse!
p arg_values.verbose
p arg_values.path
