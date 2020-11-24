# optparse_builder

A Ruby Gem for processing CLI arguments using optparse.  Adds to
optparse a compact DSL and operand parsing without being a framework.

Features:

* A  compact, simple [builder style DSL](#label-Terminology)

* Composability - Arguments can be [defined separately from their
  use](#label-Composability), allowing common arguments to be shared
  shared within a suite of programs.

* Operand parsing - Adds parsing of operands (aka positional
  arguments).

* Builds on solid ground - Uses tried and true OptParse.

* Familiarity - Arguments to OptParse#on are passed through with very
  little change, so you don't have to learn a new syntax for defining
  options.

* Not a framework - This library provides _only_ improved argument
  parsing.  There is no base class for your program to inherit from,
  no module for it to include, and no imposed structure.

* Leaves the choices to you - Stays out of your way so you can do what
  you want.

* No magic, no surprises - Mostly plain and explicit.

* Cohesion - Everything about an argument is in one place.

* Narrow API - Simple and easy to use.

* Fully documented - Includes full code documentation and examples.

* Stable API - Uses [semantic versioning][1].  Promises not to break
  your program without incrementing the major version number.

* Programmed simply - Easy to understand and modify.

* Fully tested - Extensive unit test suite.

# Hello, World

It is valuable to provide a simple example which can be modified and
expanded upon:

```
require "optparse_builder"

arg_parser = OptparseBuilder.new do |args|
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

arg_values = arg_parser.parse!
p arg_values.verbose
p arg_values.path
```

# Terminology

* Argument - An option or operand

* Option - An argument parsed by optparse, like `-v` or `--size=12`

* Switch - An option that is either present or not, like `-v`

* Value option - An option with a value, like `--size=12`

* Operand - An argument not parsed by optparse, like
  `/path/to/my/file`.  Also called a "positional argument."
  
* Required operand - An operand that must be present or an error
  results.

* Optional operand - An operand that may be present or not; if not
  present, it receives either `nil` or a default that you set.

* Splat operand - An operand that consumes all remaining operands,
  resulting in an array (possibly empty) of strings.

# Builder style DSL

You build an argument parser using a builder style DSL, like this:

```
arg_parser = OptparseBuilder.new do |args|
  args.add do |arg|
    arg.key :verbose
    arg.on "-v", "--verbose", "Be verbose"
  end
end
```

Once built, a parser is normally used like this:

    arg_values = arg_parser.parse!

and argument values retrieved using struct or hash notation:

    p arg_values.verbose
    p arg_values[:verbose]

[1]: https://semver.org/spec/v2.0.0.html

# Composability

An argument definition can be created separately from its use:

```
VERBOSE = OptparseBuilder.build_argument do |arg|
  arg.key :verbose
  arg.on "-v", "--verbose", "Print extra output"
end

parser = OptparseBuilder.new do |args|
  args.add VERBOSE
end
```

This is especially useful where a suite of programs share some
arguments in common.  Instead of defining common arguments over and
over, you can define them once and then reuse them in each program:

```
# common_arguments.rb

require "optparse_builder"

module CommonArguments
  VERBOSE = OptparseBuilder.build_argument do |arg|
    arg.key :verbose
    arg.on "-v", "--verbose", "Print extra output"
  end
end
```


```
# read_input.rb

require_relative "common_arguments"

ARG_PARSER = OptparseBuilder.new do |args|
  args.banner "Read and store the input data"
  args.add do |arg|
    arg.key 
    arg.required_operand
  end
  args.add CommonArguments::VERBOSE
end
```

```
# write_report.rb

require_relative "common_arguments"

ARG_PARSER = OptparseBuilder.new do |args|
  args.banner "Print a report based on data previously read"
  args.add CommonArguments::VERBOSE
  args.add do |arg|
    arg.key :detail
    arg.on "-d", "--detail", "Add the detail section to the report"
  end
end
```
