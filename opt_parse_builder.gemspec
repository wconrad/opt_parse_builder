lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "opt_parse_builder/version"

Gem::Specification.new do |spec|
  spec.name = "opt_parse_builder"
  spec.version = OptParseBuilder::VERSION
  spec.authors = ["Wayne Conrad"]
  spec.email = ["kf7qga@gmail.com"]
  spec.summary = "Builder DSL for optparse, with more"
  spec.license = 'MIT'
  spec.description = <<~DESCRIPTION
    Processes CLI arguments using optparse.  Adds to optparse a
    compact builder-style DSL, operand (positional argument) parsing,
    and easy sharing of common argument definitions within a suite of
    commands.  That's all it does--it is not a framework.
  DESCRIPTION
  spec.homepage = "https://github.com/wconrad/opt_parse_builder"
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have
  # been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^#{spec.bindir}/}) do |f|
    File.basename(f)
  end
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
end
