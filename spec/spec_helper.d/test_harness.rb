require "stringio"
require_relative "captures_output"

class TestHarness
  include CapturesOutput

  attr_writer :parser

  def initialize(parser = nil)
    @parser = parser
  end

  def output
    @output.string
  end

  def parse!(argv)
    status = nil
    @output = StringIO.new
    capture_stdout(@output) do
      capture_stderr(@output) do
        begin
          @parser.parse!(argv)
        rescue SystemExit => e
          status = e.status
        end
      end
    end
    if status
      @output.puts "(exit #{status})\n"
    end
  end

end
