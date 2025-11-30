require "opt_parse_builder"

# Tests that rely only on the public interface.  Changes to the
# library which require a change to an existing test are typically
# breaking changes and cause the major version number to increment.

describe "integration tests" do

  let(:test_harness) { TestHarness.new }
  
  describe "Minimal" do

    let(:parser) { OptParseBuilder.build_parser }

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "parses nothing" do
      parser.parse!([])
    end

    it "complains if it sees an operand" do
      test_harness.parser = parser
      test_harness.parse!(["foo"])
      expect(test_harness.output).to eq <<~OUTPUT
        needless argument: foo
        (exit 1)
      OUTPUT
    end

  end

  describe "Add argument to existing arguments" do

    let(:parser) do
      parser = OptParseBuilder.build_parser
      parser.add do |arg|
        arg.key :foo
        arg.on "--foo"
      end
      parser
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
                --foo
        (exit 0)
      OUTPUT
    end

  end

  describe "Argument with only a key" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is nil after parsing" do
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

  end

  describe "Argument with string key" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key "foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is nil after parsing" do
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

  end

  describe "Argument with only a key and default" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default "foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "is default before parsing" do
      expect(parser[:foo]).to eq "foo"
    end

    it "is default after parsing" do
      parser.parse!([])
      expect(parser[:foo]).to eq "foo"
    end

  end

  describe "Argument with a key, a default, and a banner line" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default "foo"
          arg.banner "There must be foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        There must be foo
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "is default before parsing" do
      expect(parser[:foo]).to eq "foo"
    end

    it "is default after parsing" do
      parser.parse!([])
      expect(parser[:foo]).to eq "foo"
    end

  end

  describe "Banner outside of an argument" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.banner "Some banner text"
        args.banner "Some more banner text"
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Some banner text
        Some more banner text
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end
  end

  describe "Banner only" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.banner "Some banner text"
          arg.banner "Some more banner text"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Some banner text
        Some more banner text
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

  end

  describe "Separator outside of an argument (deprecated)" do

    let(:parser) do
      suppress_deprecation_warnings do
        OptParseBuilder.build_parser do |args|
          args.separator "Text at the end"
          args.separator "More text at the end"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        Text at the end
        More text at the end
        (exit 0)
      OUTPUT
    end
  end

  describe "Separator only (deprecated)" do

    let(:parser) do
      suppress_deprecation_warnings do
        OptParseBuilder.build_parser do |args|
          args.add do |arg|
            arg.separator "Text at the end"
            arg.separator "More text at the end"
          end
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        Text at the end
        More text at the end
        (exit 0)
      OUTPUT
    end

  end

  describe "Footer outside of an argument" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.footer "Text at the end"
        args.footer "More text at the end"
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        Text at the end
        More text at the end
        (exit 0)
      OUTPUT
    end
  end

  describe "Footer only" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.footer "Text at the end"
          arg.footer "More text at the end"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        Text at the end
        More text at the end
        (exit 0)
      OUTPUT
    end

  end

  describe "Option with footer" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "-f", "--foo", "Do the foo thing"
          arg.footer "Footer text for foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        Footer text for foo
        (exit 0)
      OUTPUT
    end

  end

  describe "Separator with footer: false (positional)" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "-f", "--foo", "Do the foo thing"
          arg.separator "Positional separator text", footer: false
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        Positional separator text
        (exit 0)
      OUTPUT
    end

  end

  describe "Positional separator between two options" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "-f", "--foo", "First option"
          arg.separator "--- Section divider ---", footer: false
        end
        args.add do |arg|
          arg.key :bar
          arg.on "-b", "--bar", "Second option"
        end
      end
    end

    it "shows separator between the two options" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        First option
        --- Section divider ---
            -b, --bar                        Second option
        (exit 0)
      OUTPUT
    end

  end

  describe "Option with banner" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "-f", "--foo", "Do the foo thing"
          arg.banner "Banner text for foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Banner text for foo
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        (exit 0)
      OUTPUT
    end

  end

  describe "Option with separator (deprecated)" do

    let(:parser) do
      suppress_deprecation_warnings do
        OptParseBuilder.build_parser do |args|
          args.add do |arg|
            arg.key :foo
            arg.on "-f", "--foo", "Do the foo thing"
            arg.separator "Separator text for foo"
          end
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        Separator text for foo
        (exit 0)
      OUTPUT
    end

  end

  describe "Simple option, no default" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "-f", "--foo", "Do the foo thing"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is nil after parsing when not selected" do
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

    it "is true after parsing when selected" do
      parser.parse!(["-f"])
      expect(parser[:foo]).to eq true
    end

  end

  describe "Simple option with default" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default false
          arg.on "-f", "--foo", "Do the foo thing"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        (exit 0)
      OUTPUT
    end

    it "has default value before parsing" do
      expect(parser[:foo]).to eq false
    end

    it "has default value after parsing when not selected" do
      parser.parse!([])
      expect(parser[:foo]).to eq false
    end

    it "is true after parsing when selected" do
      parser.parse!(["-f"])
      expect(parser[:foo]).to eq true
    end
    
  end

  describe "Simple option with handler" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :verbose
          arg.default 0
          arg.on "-v", "--verbose"
          arg.on "Increase output (can give more than once)"
          arg.handler do |argument, _value|
            argument.value += 1
          end
        end
      end
    end

    it "is default before parsing" do
      expect(parser[:verbose]).to eq 0
    end

    it "is default after parsing when not selected" do
      parser.parse!([])
      expect(parser[:verbose]).to eq 0
    end

    it "is set once, using the handler" do
      parser.parse!(["-v"])
      expect(parser[:verbose]).to eq 1
    end

    it "is set twice, using the handler" do
      parser.parse!(["-vv"])
      expect(parser[:verbose]).to eq 2
    end
    
  end

  describe "Option with value, no default" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "--foo=VALUE", "Set foo to VALUE"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
                --foo=VALUE                  Set foo to VALUE
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is nil after parsing when not set" do
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

    it "is the appropriate value when set" do
      parser.parse!(["--foo=BAR"])
      expect(parser[:foo]).to eq "BAR"
    end
    
  end

  describe "Option with value, with default" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default "default"
          arg.on "--foo=VALUE", "Set foo to VALUE (_DEFAULT_)"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
                --foo=VALUE                  Set foo to VALUE (default)
        (exit 0)
      OUTPUT
    end

    it "is default before parsing" do
      expect(parser[:foo]).to eq "default"
    end

    it "is default after parsing when not set" do
      parser.parse!([])
      expect(parser[:foo]).to eq "default"
    end

    it "is the appropriate value when set" do
      parser.parse!(["--foo=BAR"])
      expect(parser[:foo]).to eq "BAR"
    end
    
  end

  describe "Option with value, specified over multiple lines" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "--foo=INT"
          arg.on Integer
          arg.on "Set foo to INT"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
                --foo=INT                    Set foo to INT
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is nil after parsing when not set" do
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

    it "is the appropriate value when set" do
      parser.parse!(["--foo=123"])
      expect(parser[:foo]).to eq 123
    end
    
  end

  describe "Option with value and handler" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "--square=N", Integer, "Do the foo thing"
          arg.handler do |argument, value|
            argument.value = value ** 2
          end
        end
      end
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is nil after parsing when not selected" do
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

    it "is set to the translator output when parsing" do
      parser.parse!(["--square=16"])
      expect(parser[:foo]).to eq 256
    end
    
  end

  specify "Option must have a key" do
    expect do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.on "-f", "--foo", "Do the foo thing"
        end
      end
    end.to raise_error(OptParseBuilder::BuildError, /requires a key/)
  end

  specify "Default must have a key" do
    parser = OptParseBuilder.build_parser
    expect do
      parser.add do |arg|
        arg.default 123
      end
    end.to raise_error(OptParseBuilder::BuildError, /requires a key/)
  end

  it "is an error if a key is duplicated" do
    parser = OptParseBuilder.build_parser
    parser.add do |arg|
      arg.key :foo
    end
    expect do
      parser.add do |arg|
        arg.key :foo
      end
    end.to raise_error(OptParseBuilder::BuildError, "duplicate key foo")
  end

  describe "Build argument separately" do

    let(:parser) do
      arg = OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.on "-f", "--foo", "Do the foo thing"
      end
      OptParseBuilder.build_parser do |args|
        args.add arg
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        (exit 0)
      OUTPUT
    end
    
  end

  describe "Build argument separately (build errors)" do

    it "is an error to supply an argument and a block" do
      arg1 = OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.on "-f", "--foo", "Do the foo thing"
      end
      parser = OptParseBuilder.build_parser
      expect do
        parser.add(arg1) do |arg|
          arg.banner "A banner"
        end
      end.to raise_error(OptParseBuilder::BuildError,
                         "Need exactly 1 of arg and block")
    end

    it "is an error to supply neither an argument nor a block" do
      parser = OptParseBuilder.build_parser
      expect do
        parser.add
      end.to raise_error(OptParseBuilder::BuildError,
                         "Need exactly 1 of arg and block")
    end
    
  end

  describe "accessing values in the OptParseBuilder" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default "foo"
        end
      end
    end

    it "can be accessed like a hash, with a string key" do
      expect(parser["foo"]).to eq "foo"
    end

    it "can be accessed like a hash, with a symbol key" do
      expect(parser[:foo]).to eq "foo"
    end

  end

  describe "values collection, from constant" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default "foo"
        end
      end
    end
    let(:arg_values) {parser.values}

    it "can be accessed like a struct" do
      expect(arg_values.foo).to eq "foo"
    end

  end

  describe "values collection, from option" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on("--foo")
        end
      end
    end
    let(:arg_values) {parser.values}

    it "can be accessed like a struct" do
      parser.parse!(["--foo"])
      expect(arg_values.foo).to be_truthy
    end

  end

  describe "values collection, from optional operand" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.optional_operand
        end
      end
    end
    let(:arg_values) {parser.values}

    it "can be accessed like a struct" do
      parser.parse!(["foo"])
      expect(arg_values.foo).to eq "foo"
    end

  end

  describe "values collection, from required operand" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.required_operand
        end
      end
    end
    let(:arg_values) {parser.values}

    it "can be accessed like a struct" do
      parser.parse!(["foo"])
      expect(arg_values.foo).to eq "foo"
    end

  end

  describe "values collection, from splat operand" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.splat_operand
        end
      end
    end
    let(:arg_values) {parser.values}

    it "can be accessed like a struct" do
      parser.parse!(["foo", "bar"])
      expect(arg_values.foo).to eq ["foo", "bar"]
    end

  end

  describe "values collection, various methods of accessing" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default "foo"
        end
      end
    end
    let(:arg_values) {parser.values}

    it "can be accessed like a struct" do
      expect(arg_values.foo).to eq "foo"
    end

    it "can be accessed like a hash, with a symbol key" do
      expect(arg_values[:foo]).to eq "foo"
    end

    it "can be accessed like a hash, with a string key" do
      expect(arg_values["foo"]).to eq "foo"
    end

    it "reports that a key exists" do
      expect(arg_values.has_key?("foo")).to be_truthy
    end

    it "reports that a key does not exist" do
      expect(arg_values.has_key?("bar")).to be_falsey
    end

    it "errors when accessing an unknown key like a struct" do
      expect do
        arg_values.bar
      end.to raise_error NoMethodError, /\bbar\b/
    end

    it "responds to methods for keys that exist (symbol)" do
      expect(arg_values.respond_to?(:foo)).to be_truthy
    end

    it "responds to methods for keys that exist (string)" do
      expect(arg_values.respond_to?("foo")).to be_truthy
    end

    it "does not respond to methods for keys that don't exist" do
      expect(arg_values.respond_to?(:bar)).to be_falsey
    end

  end

  describe "parse! returns a value collection" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.default "foo"
        end
      end
    end
    let(:arg_values) {parser.values}

    it "can be accessed like a struct" do
      values = parser.parse!([])
      expect(values.foo).to eq "foo"
    end

  end

  describe "bare argument" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "has no values" do
      expect(parser.values).to be_empty
    end

  end

  describe "Add argument bundle (syntax 1)" do

    let(:parser) do
      bundle = OptParseBuilder.build_bundle do |bundler|
        bundler.add do |arg|
          arg.banner "A banner line"
        end
        bundler.add do |arg|
          arg.banner "Another banner line"
        end
      end
      OptParseBuilder.build_parser do |args|
        args.add bundle
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        A banner line
        Another banner line
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end
    
  end

  describe "Add argument bundle (syntax 2)" do

    let(:parser) do
      arg1 = OptParseBuilder.build_argument do |arg|
        arg.banner "A banner line"
      end
      arg2 = OptParseBuilder.build_argument do |arg|
        arg.banner "Another banner line"
      end
      bundle = OptParseBuilder.build_bundle do |bundler|
        bundler.add arg1
        bundler.add arg2
      end
      OptParseBuilder.build_parser do |args|
        args.add bundle
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        A banner line
        Another banner line
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end
    
  end

  describe "Add argument bundle (build errors)" do

    it "is an error if neither an argument nor a block is supplied" do
      expect do
        OptParseBuilder.build_bundle do |bundler|
          bundler.add
        end
      end.to raise_error(OptParseBuilder::BuildError,
                         "Need exactly 1 of arg and block")
    end

    it "is an error if both an argument and a block is supplied" do
      arg1 = OptParseBuilder.build_argument do |arg|
        arg.banner "A banner line"
      end
      expect do
        OptParseBuilder.build_bundle do |bundler|
          bundler.add(arg1) do |arg|
            arg.banner "Another banner line"
          end
        end
      end.to raise_error(OptParseBuilder::BuildError,
                         "Need exactly 1 of arg and block")
    end

    it "is an error for an arg to be both an option and an optional operand" do
      parser = OptParseBuilder.build_parser
      expect do
        parser.add do |arg|
          arg.key :foo
          arg.on "-f"
          arg.optional_operand
        end
      end.to raise_error(OptParseBuilder::BuildError,
                         "Argument cannot be both an option and an operand")
    end

  end

  describe "Optional operand" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.optional_operand
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<foo>]
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is nil after parsing when not given" do
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

    it "is set after parsing when given" do
      parser.parse!(["foo"])
      expect(parser[:foo]).to eq "foo"
    end
    
  end

  describe "Optional operand with specific help name" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.optional_operand help_name: "the foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<the foo>]
        (exit 0)
      OUTPUT
    end

  end
  
  describe "Required operand" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.required_operand
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] <foo>
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "is an error when not given" do
      test_harness.parser = parser
      test_harness.parse!([])
      expect(test_harness.output).to eq <<~OUTPUT
        missing argument: <foo>
        (exit 1)
      OUTPUT
    end

    it "is set after parsing when given" do
      parser.parse!(["foo"])
      expect(parser[:foo]).to eq "foo"
    end
    
  end

  describe "Required operand with underscores in the key" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo_bar
          arg.required_operand
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] <foo bar>
        (exit 0)
      OUTPUT
    end

  end

  describe "Required operand with specific help name" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.required_operand help_name: "the foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] <the foo>
        (exit 0)
      OUTPUT
    end

  end

  describe "Splat operand" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.splat_operand
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<foo>...]
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(parser[:foo]).to be_nil
    end

    it "accepts no arguments" do
      parser.parse!([])
      expect(parser[:foo]).to eq []
    end

    it "accepts one argument" do
      parser.parse!(["foo"])
      expect(parser[:foo]).to eq ["foo"]
    end

    it "accepts two arguments" do
      parser.parse!(["foo", "bar"])
      expect(parser[:foo]).to eq ["foo", "bar"]
    end
    
  end

  describe "Splat operand with specific help name" do
    
    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.splat_operand help_name: "the foo"
        end
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<the foo>...]
        (exit 0)
      OUTPUT
    end

  end

  it "consumes argv" do
    parser = OptParseBuilder.build_parser do |args|
      args.add do |arg|
        arg.key :foo
        arg.on "--foo"
      end
      args.add do |arg|
        arg.key :bar
        arg.optional_operand
      end
      args.add do |arg|
        arg.key :baz
        arg.splat_operand
      end
    end
    argv = ["--foo", "bar", "baz", "quux"]
    parser.parse!(argv)
    expect(argv).to be_empty
  end

  describe "reset (option without default)" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "--foo"
        end
      end
    end

    it "is set after parsing, but nil after reset" do
      parser.parse!(["--foo"])
      expect(parser[:foo]).to be_truthy
      parser.reset
      expect(parser[:foo]).to be_nil
    end

  end

  describe "reset (option with default)" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "--foo"
          arg.default "foo"
        end
      end
    end

    it "is set after parsing, but default after reset" do
      parser.parse!(["--foo"])
      expect(parser[:foo]).to be_truthy
      parser.reset
      expect(parser[:foo]).to eq "foo"
    end

  end

  describe "reparse (option without default)" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "--foo"
        end
      end
    end

    it "can be reparsed" do
      parser.parse!(["--foo"])
      expect(parser[:foo]).to be_truthy
      parser.parse!([])
      expect(parser[:foo]).to be_nil
    end

  end

  describe "reparse (option with default)" do

    let(:parser) do OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
          arg.on "--foo"
          arg.default "foo"
        end
      end
    end

    it "can be reparsed" do
      parser.parse!(["--foo"])
      expect(parser[:foo]).to be_truthy
      parser.parse!([])
      expect(parser[:foo]).to eq "foo"
    end

  end

  describe "knowing if an argument key is present" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :foo
        end
      end
    end

    it "reports that a key is present" do
      expect(parser.has_key?(:foo)).to be_truthy
    end

    it "reports that a key is present (string instead of symbol)" do
      expect(parser.has_key?("foo")).to be_truthy
    end

    it "reports that a key not present" do
      expect(parser.has_key?(:bar)).to be_falsey
    end
    
  end

  describe "allowing unparsed operands" do

    let(:parser) { OptParseBuilder.build_parser }

    it "prohibits unparsed operands by default" do
      test_harness.parser = parser
      test_harness.parse!(["foo"])
      expect(test_harness.output).to eq <<~OUTPUT
        needless argument: foo
        (exit 1)
      OUTPUT
    end

    it "explicitly prohibits unparsed operands" do
      parser.allow_unparsed_operands = false
      test_harness.parser = parser
      test_harness.parse!(["foo"])
      expect(test_harness.output).to eq <<~OUTPUT
        needless argument: foo
        (exit 1)
      OUTPUT
    end

    it "explicitly allows unparsed operands" do
      parser.allow_unparsed_operands = true
      argv = ["foo"]
      parser.parse!(argv)
      expect(argv).to eq ["foo"]
    end
    
  end

  describe "sharing arguments" do

    let(:arg) do
      OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.optional_operand
      end
    end

    let(:parser1) do
      OptParseBuilder.build_parser do |args|
        args.add arg
      end
    end

    let(:parser2) do
      OptParseBuilder.build_parser do |args|
        args.add arg
      end
    end

    specify do
      parser1.parse!(["1"])
      parser2.parse!(["2"])
      expect(parser1[:foo]).to eq "1"
      expect(parser2[:foo]).to eq "2"
    end
    
  end

  describe "sharing bundles" do

    let(:bundle) do
      OptParseBuilder.build_bundle do |bundler|
        bundler.add do |arg|
          arg.key :foo
          arg.optional_operand
        end
        # Needed to keep bundle from being simplified
        bundler.add do |arg|
          arg.banner "banner"
        end
      end
    end

    let(:parser1) do
      OptParseBuilder.build_parser do |args|
        args.add bundle
      end
    end

    let(:parser2) do
      OptParseBuilder.build_parser do |args|
        args.add bundle
      end
    end

    specify do
      parser1.parse!(["1"])
      parser2.parse!(["2"])
      expect(parser1[:foo]).to eq "1"
      expect(parser2[:foo]).to eq "2"
    end

  end

  it "is a build error if an operand is both required and optional" do
    expect do
      OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.required_operand
        arg.optional_operand
      end
    end.to raise_error OptParseBuilder::BuildError,
                       "Argument is already an operand"
  end

  it "is a build error if an operand is both optional and splat" do
    expect do
      OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.optional_operand
        arg.splat_operand
      end
    end.to raise_error OptParseBuilder::BuildError,
                       "Argument is already an operand"
  end

  it "is a build error if an operand is both splat and required" do
    expect do
      OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.splat_operand
        arg.required_operand
      end
    end.to raise_error OptParseBuilder::BuildError,
                       "Argument is already an operand"
  end

  describe "multiple operands, out of order" do

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add do |arg|
          arg.key :four
          arg.splat_operand
        end
        args.add do |arg|
          arg.key :one
          arg.required_operand
        end
        args.add do |arg|
          arg.key :two
          arg.required_operand
        end
        args.add do |arg|
          arg.key :three
          arg.optional_operand
        end
      end
    end

    it "accepts two operands" do
      parser.parse!(["1", "2"])
      expect(parser[:one]).to eq "1"
      expect(parser[:two]).to eq "2"
      expect(parser[:three]).to be_nil
      expect(parser[:four]).to be_empty
    end
    
  end

  describe "multiple operands, out of order from bundles" do

    let(:bundle1) do
      OptParseBuilder.build_bundle  do |bundler|
        bundler.add do |arg|
          arg.key :four
          arg.splat_operand
        end
        bundler.add do |arg|
          arg.key :one
          arg.required_operand
        end
      end
    end

    let(:bundle2) do
      OptParseBuilder.build_bundle  do |bundler|
        bundler.add do |arg|
          arg.key :two
          arg.required_operand
        end
        bundler.add do |arg|
          arg.key :three
          arg.optional_operand
        end
      end
    end

    let(:parser) do
      OptParseBuilder.build_parser do |args|
        args.add bundle1
        args.add bundle2
      end
    end

    it "accepts two operands" do
      parser.parse!(["1", "2"])
      expect(parser[:one]).to eq "1"
      expect(parser[:two]).to eq "2"
      expect(parser[:three]).to be_nil
      expect(parser[:four]).to be_empty
    end
    
  end

  describe "nested bundles" do
    let(:parser) do
      inner_bundle = OptParseBuilder.build_bundle do |bundler|
        bundler.add do |arg|
          arg.key :foo
          arg.default 1
        end
      end
      outer_bundle = OptParseBuilder.build_bundle do |bundler|
        bundler.add(inner_bundle)
      end
      OptParseBuilder.build_parser do |args|
        args.add outer_bundle
      end
    end

    it "should flatten the bundles" do
      expect(parser[:foo]).to eq 1
    end
    
  end

  describe "convert required operand to optional" do

    let(:parser) do
      arg = OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.required_operand
      end
      OptParseBuilder.build_parser do |args|
        args.add arg.optional
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<foo>]
        (exit 0)
      OUTPUT
    end

  end

  describe "Convert argument bundle to operand" do

    let(:arg) do
      OptParseBuilder.build_bundle do |args|
        args.add { |arg| arg.key :foo }
        args.add { |arg| arg.key :bar }
      end
    end

    it "cannot be converted to a required operand" do
      expect do
        arg.required
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

    it "cannot be converted to an optional operand" do
      expect do
        arg.optional
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

  end

  describe "Convert banner argument to operand" do

    let(:arg) do
      OptParseBuilder.build_argument do |arg|
        arg.banner "banner"
      end
    end

    it "cannot be converted to a required operand" do
      expect do
        arg.required
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

    it "cannot be converted to an optional operand" do
      expect do
        arg.optional
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

  end

  describe "Convert separator argument to operand" do

    let(:arg) do
      suppress_deprecation_warnings do
        OptParseBuilder.build_argument do |arg|
          arg.separator "separator"
        end
      end
    end

    it "cannot be converted to a required operand" do
      expect do
        arg.required
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

    it "cannot be converted to an optional operand" do
      expect do
        arg.optional
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

  end

  describe "Convert constant argument to operand" do

    let(:arg) do
      OptParseBuilder.build_argument do |arg|
        arg.key :i
        arg.default 123
      end
    end

    it "cannot be converted to a required operand" do
      expect do
        arg.required
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

    it "cannot be converted to an optional operand" do
      expect do
        arg.optional
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

  end

  describe "Convert null argument to operand" do

    let(:arg) do
      OptParseBuilder.build_argument do |arg|
      end
    end

    it "cannot be converted to a required operand" do
      expect do
        arg.required
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

    it "cannot be converted to an optional operand" do
      expect do
        arg.optional
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

  end

  describe "Convert option to operand" do

    let(:arg) do
      OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.on "-f"
      end
    end

    it "cannot be converted to a required operand" do
      expect do
        arg.required
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

    it "cannot be converted to an optional operand" do
      expect do
        arg.optional
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

  end

  describe "Convert splat operand to operand" do

    let(:arg) do
      OptParseBuilder.build_argument do |arg|
        arg.key :paths
        arg.splat_operand
      end
    end

    it "cannot be converted to a required operand" do
      expect do
        arg.required
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

    it "cannot be converted to an optional operand" do
      expect do
        arg.optional
      end.to raise_error(OptParseBuilder::BuildError, /cannot convert/)
    end

  end

  describe "convert required operand to required operand" do

    let(:parser) do
      arg = OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.required_operand
      end
      OptParseBuilder.build_parser do |args|
        args.add arg.required
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] <foo>
        (exit 0)
      OUTPUT
    end

  end

  describe "convert optional operand to optional operand" do

    let(:parser) do
      arg = OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.optional_operand
      end
      OptParseBuilder.build_parser do |args|
        args.add arg.optional
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<foo>]
        (exit 0)
      OUTPUT
    end

  end

  describe "convert optional operand to required" do

    let(:parser) do
      arg = OptParseBuilder.build_argument do |arg|
        arg.key :foo
        arg.optional_operand
      end
      OptParseBuilder.build_parser do |args|
        args.add arg.required
      end
    end

    it "prints help" do
      test_harness.parser = parser
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] <foo>
        (exit 0)
      OUTPUT
    end

  end

  it "defaults tp parsing ARGV" do
    parser = OptParseBuilder.build_parser do |args|
      args.add do |arg|
        arg.key :foo
        arg.splat_operand
      end
    end
    with_argv(["1", "2"]) do
      parser.parse!
      expect(parser[:foo]).to eq ["1", "2"]
      expect(ARGV).to be_empty
    end
  end
  
end
