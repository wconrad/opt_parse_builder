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

  describe "access argument via method" do

    let(:args) do
      args = ComposableArguments.new
      args.add do |arg|
        arg.key :foo
        arg.default "foo"
      end
      args.add do |arg|
        arg.key :add
        arg.default "add"
      end
      args
    end

    it "is accessible" do
      expect(args.foo).to eq "foo"
    end

    it "access a key named 'add' (a public method)" do
      expect(args.add).to eq "add"
    end

    it "errors on a non-existent key" do
      expect do
        args.bar
      end.to raise_error(NoMethodError, /\bbar\b/)
    end

  end

end
