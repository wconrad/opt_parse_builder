#!/usr/bin/env ruby

require "optparse_builder"

ARG_PARSER = OptparseBuilder.new do |args|
  args.banner "A simple example"
  args.add do |arg|
    arg.key :path
    arg.required_operand
  end
  args.add do |arg|
    arg.key :verbose
    arg.on "-v", "--verbose", "Be verbose"
  end
  args.separator "Some explanatory text at the bottom"
end

arg_values = ARG_PARSER.parse!
p arg_values.verbose
p arg_values.path
