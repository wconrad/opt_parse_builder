require "stringio"

module CapturesOutput
  
  def capture_stdout(target)
    orig_stdout = $stdout
    $stdout = target
    begin
      yield
    ensure
      $stdout = orig_stdout
    end
  end

  def capture_stderr(target = StringIO.new)
    orig_stderr = $stderr
    $stderr = target
    begin
      yield
    ensure
      $stderr = orig_stderr
    end
  end

  def suppress_deprecation_warnings
    capture_stderr do
      yield
    end
  end

end

RSpec.configure do |config|
  config.include CapturesOutput
end
