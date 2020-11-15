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

  describe "Simple option" do

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

end
