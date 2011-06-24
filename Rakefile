require './lib/tracksperanto'
begin
  require 'hoe'
  
  Hoe::RUBY_FLAGS.gsub!(/^\-w/, '') # No thanks undefined ivar warnings
  
  Hoe.spec('tracksperanto') do | p |
    p.readme_file   = 'README.rdoc'
    p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
    p.version = Tracksperanto::VERSION
    
    p.extra_deps = {"progressbar" => ">=0", "update_hints" => ">=0" }
    p.extra_dev_deps = {"flexmock" => ">=0", "cli_test" => "~>1.0.0"}
    p.rubyforge_name = 'guerilla-di'
    p.developer('Julik Tarkhanov', 'me@julik.nl')
    p.clean_globs = %w( **/.DS_Store  coverage.info **/*.rbc .idea .yardoc)
  end
rescue LoadError
  
  $stderr.puts "Meta-operations on this package require Hoe"
  
  require 'rake/testtask'
  desc "Run all tests"
  Rake::TestTask.new("test") do |t|
    t.libs << "test"
    t.pattern = 'test/**/test_*.rb'
    t.verbose = true
  end

  task :default => [ :test ]
end


