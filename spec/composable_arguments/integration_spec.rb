require "composable_arguments"

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

  describe "Build and add argument bundle" do

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

end
