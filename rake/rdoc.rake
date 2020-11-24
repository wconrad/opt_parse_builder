require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.markup = :markdown
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end
