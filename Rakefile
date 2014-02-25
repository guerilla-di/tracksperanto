require './lib/tracksperanto'
require 'rake/hooks'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.version = Tracksperanto::VERSION
  gem.name = "tracksperanto"
  gem.summary = "A universal 2D tracks converter"
  gem.description = "Converts 2D track exports between different apps like Flame, MatchMover, PFTrack..."
  gem.email = "me@julik.nl"
  gem.homepage = "http://guerilla-di.org/tracksperanto"
  gem.authors = ["Julik Tarkhanov"]
  gem.extra_rdoc_files << "DEVELOPER_DOCS.rdoc"
  gem.license = 'MIT'
  gem.executables = ["tracksperanto"]

  # Do not package up test fixtures
  gem.files.exclude "test/import/samples"
  gem.files.exclude "test/import/samples/*/*.*"
  gem.files.exclude "test/subpixel"

  # Do not package invisibles
  gem.files.exclude ".*"
end

Jeweler::RubygemsDotOrgTasks.new


require 'rake/testtask'
desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

# Automatically update the supported format list
after :test do
  formats = StringIO.new
  
  formats.puts(" ")
  formats.puts(" ")
  formats.puts('### Formats Tracksperanto can read')
  formats.puts(" ")
  Tracksperanto.importers.each do | import_mdoule |
    formats.puts("* %s" % import_mdoule.human_name)
  end
  
  formats.puts(" ")
  formats.puts('### Formats Tracksperanto can export to')
  formats.puts(" ")
  Tracksperanto.exporters.each do | export_module |
    formats.puts("* %s" % export_module.human_name)
  end
  formats.puts(" ")
  
  readme_text = File.read(File.dirname(__FILE__) + "/README.md")
  three = readme_text.split('---')
  raise "Should split in 3" unless three.length == 3
  three[1] = formats.string
  
  File.open(File.dirname(__FILE__) + "/README.md", "w") do | f |
    f.write(three.join('---'))
  end
  
end

task :default => [ :test ]

