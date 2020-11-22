require "rubygems"
require "bundler"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

$:.unshift(File.dirname(__FILE__) + "/lib")
Dir["rake/**/*.rake"].sort.each { |path| load path }
