require "bundler/setup"

lib_dir = File.join(__dir__, "../../lib")
if File.directory?(lib_dir)
  $:.prepend lib_dir
end
                    
require "opt_parse_builder"
