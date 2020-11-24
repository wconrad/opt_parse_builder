# optparse_builder

A CLI argument parser using optparse.

Features:

* Limited scope - Argument parsing _only_.  Your program does not have
  to inherit from some specific class or have any imposed structure.

* Builds on solid ground - Uses tried and true OptParse.

* Familiarity - Arguments to Optparse#on with very little change, so
  you don't have to learn a new syntax for definition options.

* A builder style DSL.

* Cohesion - Everything about an argument is in one place

* Composability - Argument definitions can be defined separately and
  then glued together, allowing them to be shared within a suite of
  programs.

* Operand parsing - Adds parsing of operands (aka positional
  arguments).

* Fully documented

# Terminology

* Argument - An option or operand
  * Option - An argument parsed by optparse, like `-v` or `--size=12`
  * Operand - An argument not parsed by optparse, like
    `/path/to/my/file`.  Aka "positional argument."
