# optparse_builder

A Ruby Gem for processing CLI arguments using optparse.  Adds to
optparse a compact DSL and operand parsing without being a framework.

Features:

* A  compact, simple builder style DSL.

* Composability - Argument definitions can be defined separately and
  then glued together, allowing them to be shared within a suite of
  programs.

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

* Fully documented - Includes code documentation and examples.

* Stable API - Uses [semantic versioning][1].  Promises not to break
  your program without incrementing the major version number.

* Programmed simply - Easy to understand and modify.

* Fully tested - Extensive unit test suite.

# Hello, World

It is valuable to provide a simple example which can be modified and
expanded upon:

```
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
```

# Terminology

* Argument - An option or operand

* Option - An argument parsed by optparse, like `-v` or `--size=12`

* Operand - An argument not parsed by optparse, like
  `/path/to/my/file`.  Aka "positional argument."
  
* Required operand - An operand that must be present or an error
  results.

* Optional operand - An operand that may be present or not; if not
  present, it receives either `nil` or a default that you set.

* Splat operand - An operand that consumes all remaining operands,
  resulting in an array (possibly empty) of strings.

[1]: https://semver.org/spec/v2.0.0.html
