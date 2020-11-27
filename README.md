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

arg_parser = OptParseBuilder.build_parser do |args|
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
gem 'opt_parse_builder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opt_parse_builder

# Explanation of some features

## Builder style DSL

You build an argument parser using a builder style DSL, like this:

```ruby
arg_parser = OptParseBuilder.build_parser do |args|
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

parser = OptParseBuilder.build_parser do |args|
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

ARG_PARSER = OptParseBuilder.build_parser do |args|
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

ARG_PARSER = OptParseBuilder.build_parser do |args|
  args.banner "Print a report based on data previously read"
  args.add CommonArguments::VERBOSE
  args.add do |arg|
    arg.key :detail
    arg.on "-d", "--detail", "Add the detail section to the report"
  end
end
```

When adding a pre-built operand to a parser, you can change change
it from required to optional:

```
PATH = OptParseBuilder.build_argument do |arg|
  arg.key :path
  arg.required_operand
end

ARG_PARSER = OptParser.build_parser do |args|
  args.add PATH.optional
end
```

or from optional to required:

```
PATH = OptParseBuilder.build_argument do |arg|
  arg.key :path
  arg.optional_operand
end

ARG_PARSER = OptParser.build_parser do |args|
  args.add PATH.required
end
```

# Argument Building Examples

Most of these examples use a shorthand where the surrounding code
is not shown:

    arg.key = :foo
    arg.on "-f"

With the surrounding code, that would be this:

    parser = OptparserBuilder.new do |args|
      args.add do |arg|
        arg.key = :foo
        arg.on = "-f"
      end
    end

or this:

    arg = OptParseBuilder.build_argument do |arg|
      arg.key = :foo
      arg.on = "-f"
    end

## Null argument

A null argument, having no value or visible effect:

    OptParseBuilder.build_argument do |arg|
    end

This has little value to you, but it fell out of the design for
free, and it is useful in the implementation.

## Banner only

An argument with only banner text (but see OptParseBuilder#banner
for the usual way to do this).  "Banner" is how OptParse describes
text that appears at the top of the --help output.

    OptParseBuilder.build_argument do |arg|
      arg.banner "Some banner text"
      arg.banner "A second line of banner text"
      arg.banner <<~BANNER
        A third line
        A fourth line
      BANNER
    end

Applicable builder methods:

* banner

Banner text can be added to any argument.

## Separator only

An argument with only separator text (but see
OptParseBuilder#banner for the usual way to do this).  "Separator"
is how OptParse describes text that appears at the bottom of the
--help output.

    OptParseBuilder.build_argument do |arg|
      arg.serparator "Separator text"
      arg.serparator "A second line of separator text"
      arg.serparator <<~SERPARATOR
        A third line
        A fourth line
      SERPARATOR
    end

Applicable builder methods:

* separator

Separator text can be added to any argument.

## Constant value

An argument with a constant value.

    OptParseBuilder.build_argument do |arg|
      arg.key :limit
      arg.default 12345
    end

Applicable builder methods:

* key
* default
* banner (optional)
* separator (optional)

This is of limited value, but it fell out of the design for free.

## Boolean option (switch)

A boolean option (switch) parsed by OptParse:

    OptParseBuilder.build_argument do |arg|
      arg.key :quiet
      arg.on "-q", "--quiet", "Suppress normal output"
    end

Applicable builder methods:

* key
* on
* default (optional)
* banner (optional)
* separator (optional)

## Value option

A value option parsed by OptParse:

    OptParseBuilder.build_argument do |arg|
      arg.key :iterations
      arg.default 100
      arg.on "-i", "--iterations=N",
      arg.on "Number of iterations (default _DEFAULT_)"
    end

Applicable builder methods:

* key
* on
* default (optional)
* banner (optional)
* separator (optional)

## Required operand

A required operand consumes one argument, with an error if there
isn't one to consume.

This example overrides the help name, which is used to describe
the operand in the --help text.  Optional and splat arguments can
also have a help name override.

    OptParseBuilder.build_argument do |arg|
      arg.key :group
      arg.required_operand help_name: "resource group"
      arg.optional_operand
    end

Applicable builder methods:

* key
* required_operand
* default (optional)
* banner (optional)
* separator (optional)

## Optional operand

An optional operand consumes one argument.  If there isn't an
argument to consume, then the value is either nil (if no default
was specified), or the specified default value.

    OptParseBuilder.build_argument do |arg|
      arg.key :group_name
      arg.default "main"
      arg.optional_operand
    end

Applicable builder methods:

* key
* optional_operand
* default (optional)
* banner (optional)
* separator (optional)

## Splat Operand

A "splat" operand consumes all remaining arguments.  Its value is
always an array.

    OptParseBuilder.build_argument do |arg|
      arg.key :input_path
      arg.optional_operand
    end

Applicable builder methods:

* key
* splat_operand
* default (optional)
* banner (optional)
* separator (optional)

# Development

After checking out the repo, run `bundle` to install dependencies.
Then run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake
install`.  To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

# Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/wconrad/opt_parse_builder.

# Terminology

These terms are used in this library's code and documentation:

* Argument - An option or operand; a single element of ARGV

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
