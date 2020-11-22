require "composable_arguments"

# Tests that rely only on the public interface.  Changes to the
# library which require a change to an existing test are typically
# breaking changes and cause the major version number to increment.

describe "integration tests" do

  let(:test_harness) { TestHarness.new }
  
  describe "Minimal" do

    let(:args) { ComposableArguments.new }

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "parses nothing" do
      args.parse!([])
    end

    it "complains if it sees an operand" do
      test_harness.args = args
      test_harness.parse!(["foo"])
      expect(test_harness.output).to eq <<~OUTPUT
        needless argument: foo
        (exit 1)
      OUTPUT
    end

  end

  describe "Argument with only a key" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(args[:foo]).to be_nil
    end

    it "is nil after parsing" do
      args.parse!([])
      expect(args[:foo]).to be_nil
    end

  end

  describe "Argument with only a key and default" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.default "foo"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "is default before parsing" do
      expect(args[:foo]).to eq "foo"
    end

    it "is default after parsing" do
      args.parse!([])
      expect(args[:foo]).to eq "foo"
    end

  end

  describe "Argument with a key, a default, and a banner line" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.default "foo"
        arg.banner "There must be foo"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        There must be foo
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "is default before parsing" do
      expect(args[:foo]).to eq "foo"
    end

    it "is default after parsing" do
      args.parse!([])
      expect(args[:foo]).to eq "foo"
    end

  end

  describe "Banner only" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.banner "Some banner text"
        arg.banner "Some more banner text"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Some banner text
        Some more banner text
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

  end

  describe "Separator only" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.separator "Text at the end"
        arg.separator "More text at the end"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        Text at the end
        More text at the end
        (exit 0)
      OUTPUT
    end

  end

  describe "Option with banner" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "-f", "--foo", "Do the foo thing"
        arg.banner "Banner text for foo"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Banner text for foo
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        (exit 0)
      OUTPUT
    end

  end

  describe "Option with separator" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "-f", "--foo", "Do the foo thing"
        arg.separator "Separator text for foo"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        Separator text for foo
        (exit 0)
      OUTPUT
    end

  end

  describe "Simple option (switch), no default" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "-f", "--foo", "Do the foo thing"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(args[:foo]).to be_nil
    end

    it "is nil after parsing when not selected" do
      args.parse!([])
      expect(args[:foo]).to be_nil
    end

    it "is true after parsing when selected" do
      args.parse!(["-f"])
      expect(args[:foo]).to eq true
    end

  end

  describe "Simple option (switch) with default" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.default false
        arg.on "-f", "--foo", "Do the foo thing"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
            -f, --foo                        Do the foo thing
        (exit 0)
      OUTPUT
    end

    it "has default value before parsing" do
      expect(args[:foo]).to eq false
    end

    it "has default value after parsing when not selected" do
      args.parse!([])
      expect(args[:foo]).to eq false
    end

    it "is true after parsing when selected" do
      args.parse!(["-f"])
      expect(args[:foo]).to eq true
    end
    
  end

  describe "Option with value, no default" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "--foo=VALUE", "Set foo to VALUE"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
                --foo=VALUE                  Set foo to VALUE
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(args[:foo]).to be_nil
    end

    it "is nil after parsing when not set" do
      args.parse!([])
      expect(args[:foo]).to be_nil
    end

    it "is the appropriate value when set" do
      args.parse!(["--foo=BAR"])
      expect(args[:foo]).to eq "BAR"
    end
    
  end

  describe "Option with value, with default" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.default "default"
        arg.on "--foo=VALUE", "Set foo to VALUE (_DEFAULT_)"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
                --foo=VALUE                  Set foo to VALUE (default)
        (exit 0)
      OUTPUT
    end

    it "is default before parsing" do
      expect(args[:foo]).to eq "default"
    end

    it "is default after parsing when not set" do
      args.parse!([])
      expect(args[:foo]).to eq "default"
    end

    it "is the appropriate value when set" do
      args.parse!(["--foo=BAR"])
      expect(args[:foo]).to eq "BAR"
    end
    
  end

  describe "Option with value, specified over multiple lines" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "--foo=INT"
        arg.on Integer
        arg.on "Set foo to INT"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
                --foo=INT                    Set foo to INT
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(args[:foo]).to be_nil
    end

    it "is nil after parsing when not set" do
      args.parse!([])
      expect(args[:foo]).to be_nil
    end

    it "is the appropriate value when set" do
      args.parse!(["--foo=123"])
      expect(args[:foo]).to eq 123
    end
    
  end

  specify "Option must have a key" do
    expect do
      args = ComposableArguments.new
      args.add do |arg|
        arg.on "-f", "--foo", "Do the foo thing"
      end
    end.to raise_error(ComposableArguments::BuildError, "option requires a key")
  end

  specify "Default must have a key" do
    expect do
      args = ComposableArguments.new
      args.add do |arg|
        arg.default 123
      end
    end.to raise_error(ComposableArguments::BuildError, "default requires a key")
  end

  it "is an error if a key is duplicated" do
    args = ComposableArguments.new
    args.add do |arg|
      arg.key :foo
    end
    expect do
      args.add do |arg|
        arg.key :foo
      end
    end.to raise_error(ComposableArguments::BuildError, "duplicate key foo")
  end

  describe "Build argument separately" do

    let(:args) do
      arg = ComposableArguments.build_argument do |arg|
        arg.key :foo
        arg.on "-f", "--foo", "Do the foo thing"
      end
      args = ComposableArguments.new
      args.add arg
      args
    end

    it "prints help" do
      test_harness.args = args
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
      arg1 = ComposableArguments.build_argument do |arg|
        arg.key :foo
        arg.on "-f", "--foo", "Do the foo thing"
      end
      args = ComposableArguments.new
      expect do
        args.add(arg1) do |arg|
          arg.banner "A banner"
        end
      end.to raise_error(ComposableArguments::BuildError,
                         "Need exactly 1 of arg and block")
    end

    it "is an error to supply neither an argument nor a block" do
      args = ComposableArguments.new
      expect do
        args.add
      end.to raise_error(ComposableArguments::BuildError,
                         "Need exactly 1 of arg and block")
    end
    
  end

  describe "accessing values in the ComposableArguments" do
    
    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.default "foo"
      end
      args
    end

    it "can be accessed like a hash, with a string key" do
      expect(args["foo"]).to eq "foo"
    end

    it "can be accessed like a hash, with a symbol key" do
      expect(args[:foo]).to eq "foo"
    end

  end

  describe "accessing values in a value collection" do
    
    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.default "foo"
      end
      args
    end
    let(:arg_values) {args.values}

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

  end

  describe "bare argument" do
    
    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options]
        (exit 0)
      OUTPUT
    end

    it "has no values" do
      expect(args.values).to be_empty
    end

  end

  describe "Add argument bundle (syntax 1)" do

    let(:args) do
      bundle = ComposableArguments.build_bundle do |bundler|
        bundler.add do |arg|
          arg.banner "A banner line"
        end
        bundler.add do |arg|
          arg.banner "Another banner line"
        end
      end
      args = ComposableArguments.new
      args.add bundle
      args
    end

    it "prints help" do
      test_harness.args = args
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

    let(:args) do
      arg1 = ComposableArguments.build_argument do |arg|
        arg.banner "A banner line"
      end
      arg2 = ComposableArguments.build_argument do |arg|
        arg.banner "Another banner line"
      end
      bundle = ComposableArguments.build_bundle do |bundler|
        bundler.add arg1
        bundler.add arg2
      end
      args = ComposableArguments.new
      args.add bundle
      args
    end

    it "prints help" do
      test_harness.args = args
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
        ComposableArguments.build_bundle do |bundler|
          bundler.add
        end
      end.to raise_error(ComposableArguments::BuildError,
                         "Need exactly 1 of arg and block")
    end

    it "is an error if both an argument and a block is supplied" do
      arg1 = ComposableArguments.build_argument do |arg|
        arg.banner "A banner line"
      end
      expect do
        ComposableArguments.build_bundle do |bundler|
          bundler.add(arg1) do |arg|
            arg.banner "Another banner line"
          end
        end
      end.to raise_error(ComposableArguments::BuildError,
                         "Need exactly 1 of arg and block")
    end

    it "is an error for an arg to be both an option and an optional operand" do
      expect do
        args = ComposableArguments.new
        args.add do |arg|
          arg.key :foo
          arg.on "-f"
          arg.optional_operand
        end
      end.to raise_error(ComposableArguments::BuildError,
                         "Argument cannot be both an option and an operand")
    end

  end

  describe "Optional operand" do
    
    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.optional_operand
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<foo>]
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(args[:foo]).to be_nil
    end

    it "is nil after parsing when not given" do
      args.parse!([])
      expect(args[:foo]).to be_nil
    end

    it "is set after parsing when given" do
      args.parse!(["foo"])
      expect(args[:foo]).to eq "foo"
    end
    
  end

  describe "Optional operand with specific help name" do
    
    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.optional_operand help_name: "the foo"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] [<the foo>]
        (exit 0)
      OUTPUT
    end

  end
  
  describe "Required operand" do
    
    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.required_operand
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] <foo>
        (exit 0)
      OUTPUT
    end

    it "is nil before parsing" do
      expect(args[:foo]).to be_nil
    end

    it "is an error when not given" do
      test_harness.args = args
      test_harness.parse!([])
      expect(test_harness.output).to eq <<~OUTPUT
        missing argument: <foo>
        (exit 1)
      OUTPUT
    end

    it "is set after parsing when given" do
      args.parse!(["foo"])
      expect(args[:foo]).to eq "foo"
    end
    
  end

  describe "Required operand with specific help name" do
    
    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.required_operand help_name: "the foo"
      end
      args
    end

    it "prints help" do
      test_harness.args = args
      test_harness.parse!(["-h"])
      expect(test_harness.output).to eq <<~OUTPUT
        Usage: rspec [options] <the foo>
        (exit 0)
      OUTPUT
    end

  end

  it "consumes argv" do
    args = ComposableArguments.new
    args.add do |arg|
      arg.key :foo
      arg.on "--foo"
    end
    args.add do |arg|
      arg.key :bar
      arg.optional_operand
    end
    argv = ["--foo", "bar"]
    args.parse!(argv)
    expect(argv).to be_empty
  end

  describe "reset (option without default)" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "--foo"
      end
      args
    end

    it "is set after parsing, but nil after reset" do
      args.parse!(["--foo"])
      expect(args[:foo]).to be_truthy
      args.reset
      expect(args[:foo]).to be_nil
    end

  end

  describe "reset (option with default)" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "--foo"
        arg.default "foo"
      end
      args
    end

    it "is set after parsing, but default after reset" do
      args.parse!(["--foo"])
      expect(args[:foo]).to be_truthy
      args.reset
      expect(args[:foo]).to eq "foo"
    end

  end

  describe "reparse (option without default)" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "--foo"
      end
      args
    end

    it "can be reparsed" do
      args.parse!(["--foo"])
      expect(args[:foo]).to be_truthy
      args.parse!([])
      expect(args[:foo]).to be_nil
    end

  end

  describe "reparse (option with default)" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.on "--foo"
        arg.default "foo"
      end
      args
    end

    it "can be reparsed" do
      args.parse!(["--foo"])
      expect(args[:foo]).to be_truthy
      args.parse!([])
      expect(args[:foo]).to eq "foo"
    end

  end
  
end
