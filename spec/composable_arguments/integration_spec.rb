require "composable_arguments"

describe "integration tests" do

  include ComposableArguments

  specify "Minimal" do
    test_harness = TestHarness.new
    test_harness.args = ComposableArguments.build
    test_harness.parse!(["-h"])
    expect(test_harness.stdout).to eq <<~EOS
      Usage: rspec [options]
      (exit)
    EOS
  end

end
