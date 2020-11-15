require "composable_arguments"

describe "integration tests" do

  include ComposableArguments

  let(:test_harness) { TestHarness.new }
  
  describe "Minimal" do

    let(:args) { ComposableArguments.build }

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

end
