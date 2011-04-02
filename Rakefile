require 'rubygems'
require './lib/tracksperanto'

begin
  require 'hoe'
  # Disable spurious warnings when running tests, ActiveMagic cannot stand -w
  Hoe::RUBY_FLAGS.replace ENV['RUBY_FLAGS'] || "-I#{%w(lib test).join(File::PATH_SEPARATOR)}" + 
    (Hoe::RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')
  
  Hoe.spec('tracksperanto') do | p |
    p.readme_file   = 'README.rdoc'
    p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
    p.version = Tracksperanto::VERSION
    
    p.extra_deps = {"progressbar" => ">=0"}
    p.extra_dev_deps = {"flexmock" => ">=0"}
    p.rubyforge_name = 'guerilla-di'
    p.developer('Julik Tarkhanov', 'me@julik.nl')
    p.clean_globs = %w( **/.DS_Store  coverage.info **/*.rbc .idea .yardoc)
  end
rescue LoadError
  $stderr.puts "Meta-operations on this package require Hoe"
  task :default => [ :test ]
  
  require 'rake/testtask'
  desc "Run all tests"
  Rake::TestTask.new("test") do |t|
    t.libs << "test"
    t.pattern = 'test/**/test_*.rb'
    t.verbose = true
  end
end