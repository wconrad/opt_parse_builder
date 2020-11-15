require "stringio"

class TestHarness

  attr_writer :args
  attr_reader :stdout

  def initialize(args = nil)
    @args = args
  end

  def parse!(argv)
    system_exit = false
    @stdout = capture_stdout do
      begin
        @args.parse!(argv)
      rescue SystemExit
        system_exit = true
      end
    end
    @stdout += "(exit)\n" if system_exit
  end

  private

  def capture_stdout
    orig_stdout = $stdout
    $stdout = StringIO.new
    begin
      yield
      $stdout.string
    ensure
      $stdout = orig_stdout
    end
  end
  
end
