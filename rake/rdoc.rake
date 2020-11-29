require 'rdoc/task'

RDOC_PATHS = [
  "README.md",
  "lib",
]

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.markup = :markdown
  rdoc.rdoc_files.include(RDOC_PATHS)
end

desc "Print RDOC coverage report"
task "rdoc:coverage" do
  command = [
    "rdoc",
    "--coverage-report",
    *RDOC_PATHS,
  ]
  system(*command)
end
