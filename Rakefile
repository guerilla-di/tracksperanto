require './lib/tracksperanto'
require 'jeweler'
require 'rake/hooks'

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

after :test do
  File.open(File.dirname(__FILE__) + "/EXPORT_FORMATS.rdoc", "w") do | f |
    Tracksperanto.exporters.each do | export_module |
      f.puts("* %s" % export_module.human_name)
    end
  end
  File.open(File.dirname(__FILE__) + "/IMPORT_FORMATS.rdoc", "w") do | f |
    Tracksperanto.importers.each do | import_mdoule |
      f.puts("* %s" % import_mdoule.human_name)
    end
  end
end

task :default => [ :test ]

