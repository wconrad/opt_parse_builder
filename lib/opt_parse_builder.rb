require "optparse"

require_relative "opt_parse_builder/argument"
require_relative "opt_parse_builder/argument_builder"
require_relative "opt_parse_builder/argument_bundle"
require_relative "opt_parse_builder/argument_bundle_builder"
require_relative "opt_parse_builder/argument_values"
require_relative "opt_parse_builder/banner_argument"
require_relative "opt_parse_builder/constant_argument"
require_relative "opt_parse_builder/errors"
require_relative "opt_parse_builder/formats_operand_name"
require_relative "opt_parse_builder/has_value"
require_relative "opt_parse_builder/null_argument"
require_relative "opt_parse_builder/option_argument"
require_relative "opt_parse_builder/optional_operand_argument"
require_relative "opt_parse_builder/parser"
require_relative "opt_parse_builder/parser_builder"
require_relative "opt_parse_builder/required_operand_argument"
require_relative "opt_parse_builder/separator_argument"
require_relative "opt_parse_builder/splat_operand_argument"
require_relative "opt_parse_builder/stable_sort"

# The namespace of this library, and the sole entry point.  You never
# have to (and never should) explicitly refer to any other class or
# module of this library than this one.  There are a few other classes
# you will use, but they will be created for you by methods of this
# module.
#
# Minimal example:
#
#     arg_parser = OptParseBuilder.build_parser
#     arg_parser.parse!
#
# An example with a little bit of everything
#
#     arg_parser = OptParseBuilder.build_parser do |p|
#       parser.banner "A short description of the program"
#       parser.add do |arg|
#         arg.key :output_path
#         arg.required_operand
#       end
#       parser.add do |arg|
#         arg.key :input_paths
#         arg.splat_operand
#       end
#       parser.add do |arg|
#         arg.key :quiet
#         arg.on "-q", "--quiet", "Be quiet"
#       end
#       parser.add do |arg|
#         arg.key :size
#         arg.default 1024
#         arg.on "--size=N", Integer
#         arg.on "Size in bytes (default _DEFAULT_)"
#       end
#       parser.separator "Explanatory text at the bottom"
#     end
#     arg_values = arg_parser.parse!
#     p arg_values.quiet          # nil or true
#     p arg_values.size           # An Integer
#     p arg_values.output_path    # A string
#     p arg_values.input_paths    # An array of strings
module OptParseBuilder

  # Create a new parser.  If called without a block, returns a parser
  # than you can then add arguments to:
  #
  #     arg_parser = OptParseBuilder.build_parser
  #     arg_parser.add do |arg|
  #       arg.key :force
  #       arg.on "--force", "Force dangerous operation"
  #     end
  #
  # If called with a block, yields itself to the block:
  #
  #     arg_parser = OptParseBuilder.build_parser do |parser|
  #       arg.key :force
  #       arg.on "--force", "Force dangerous operation"
  #     end
  #
  # Note that the parser constructed using the block form can still
  # be added onto:
  #
  #     arg_parser.add do |arg|
  #       arg.key :size
  #       arg.on "--size=N", Integer, "File size in bytes"
  #     end
  #    
  def self.build_parser
    parser_builder = ParserBuilder.new
    yield parser_builder if block_given?
    parser_builder.parser
  end

  # Build an argument that can be added to a parser.  Yields an
  # ArgumentBuilder.  Returns the  argument created by the builder.
  #
  #     VERBOSE = OptParseBuilder.build_argument do |arg|
  #       arg.key :verbose
  #       arg.on "-v", "--verbose", "Print extra output"
  #     end
  #
  #     arg_parser = OptParseBuilder.build_parser do |parser|
  #       parser.add VERBOSE
  #     end
  #
  # See ArgumentBuilder for details of the different options
  # avaialable for an argument.
  #
  # Raises BuildError if the argument cannot be built or added.
  #
  # This is most useful when you are building a related suite of
  # programs that share some command-line arguments in common.  Most
  # of the time you will just add the argument using the block form of
  # OptParseBuilder#add.
  def self.build_argument
    builder = ArgumentBuilder.new
    yield builder
    builder.argument
  end

  # Build a bundle of arguments that can be added to a parser
  # together.  Yields an ArgumentBundleBuilder.
  #
  # This is useful when you have a group of arguments that go
  # together:
  #
  #     bundle = OptParseBuilder.build_bundle do |parser|
  #       parser.add do |arg|
  #         arg.key :x
  #         op.on "-x", Integer, "X coordinate"
  #       end
  #       parser.add do |arg|
  #         arg.key :y
  #         op.on "-y", Integer, "Y coordinate"
  #       end
  #     end
  #
  #     arg_parser = OptParseBuilder.build_parser do |parser|
  #       parser.add bundle
  #     end
  #
  # Raises BuildError if the argument cannot be built or added.
  #
  # This is most useful when you are building a related suite of
  # programs that share some command-line arguments in common.  Most
  # of the time you will just add the arguments using the block form
  # of OptParseBuilder#add.
  def self.build_bundle
    bundler = ArgumentBundleBuilder.new
    yield bundler
    bundler.argument
  end

end
