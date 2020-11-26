# opt_parse_builder

A Ruby Gem for processing CLI arguments using optparse.  Adds to
optparse a compact builder-style DSL, operand (positional argument)
parsing, and composability for sharing argument definitions within a
suite of commands.

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

* No magic, no surprises - Plain and explicit.

* Cohesion - Everything about an argument is defined in one place.
  You don't have to define the argument's help text in one place, the
  default value in another, etc.

* Narrow API - Simple and easy to use.

* Fully documented - Includes full code documentation and examples.

* Stable API - Uses [semantic
  versioning](ttps://semver.org/spec/v2.0.0.html).  Promises not to
  break your program without incrementing the major version number.

* Programmed simply - Easy to understand and modify.

* Fully tested - Extensive unit test suite.

# Hello, World

It is valuable to provide a simple example which can be modified and
expanded upon:

```ruby
require "opt_parse_builder"

arg_parser = OptParseBuilder.new do |args|
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

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'composable_arguments'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install composable_arguments

# Explanation of some features

## Builder style DSL

You build an argument parser using a builder style DSL, like this:

```ruby
arg_parser = OptParseBuilder.new do |args|
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

## Composability

An argument definition can be created separately from its use:

```ruby
VERBOSE = OptParseBuilder.build_argument do |arg|
  arg.key :verbose
  arg.on "-v", "--verbose", "Print extra output"
end

parser = OptParseBuilder.new do |args|
  args.add VERBOSE
end
```

This is especially useful where a suite of programs share some
arguments in common.  Instead of defining common arguments over and
over, you can define them once and then reuse them in each program:

```ruby
# common_arguments.rb

require "opt_parse_builder"

module CommonArguments
  VERBOSE = OptParseBuilder.build_argument do |arg|
    arg.key :verbose
    arg.on "-v", "--verbose", "Print extra output"
  end
end
```

```ruby
# read_input.rb

require_relative "common_arguments"

ARG_PARSER = OptParseBuilder.new do |args|
  args.banner "Read and store the input data"
  args.add do |arg|
    arg.key 
    arg.required_operand
  end
  args.add CommonArguments::VERBOSE
end
```

```ruby
# write_report.rb

require_relative "common_arguments"

ARG_PARSER = OptParseBuilder.new do |args|
  args.banner "Print a report based on data previously read"
  args.add CommonArguments::VERBOSE
  args.add do |arg|
    arg.key :detail
    arg.on "-d", "--detail", "Add the detail section to the report"
  end
end
```

## Development

After checking out the repo, run `bundle` to install dependencies.
Then run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake
install`.  To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/wconrad/opt_parse_builder.

# Terminology

These terms are used in this library's code and documentation:

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
