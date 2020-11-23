def with_argv(a)
  orig_argv = ARGV.dup
  begin
    ARGV.replace(a)
    yield
  ensure
    ARGV.replace(orig_argv)
  end
end
