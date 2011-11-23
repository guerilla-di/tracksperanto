require './lib/tracksperanto'
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

task :default => [ :test ]