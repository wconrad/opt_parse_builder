require "stringio"

class TestHarness

  attr_writer :args

  def initialize(args = nil)
    @args = args
  end

  def output
    @output.string
  end

  def parse!(argv)
    status = nil
    @output = StringIO.new
    capture_stdout do
      capture_stderr do
        begin
          @args.parse!(argv)
        rescue SystemExit => e
          status = e.status
        end
      end
    end
    if status
      @output.puts "(exit #{status})\n"
    end
  end

  private

  def capture_stdout
    orig_stdout = $stdout
    $stdout = @output
    begin
      yield
    ensure
      $stdout = orig_stdout
    end
  end

  def capture_stderr
    orig_stderr = $stderr
    $stderr = @output
    begin
      yield
    ensure
      $stderr = orig_stderr
    end
  end
  
end
