require './lib/tracksperanto'
begin
  gem "hoe", "2.7.0" if RUBY_VERSION < "1.9" # Travis-CI doesn't want to love Hoe 2.8+
  require 'hoe'
  
  Hoe::RUBY_FLAGS.gsub!(/^\-w/, '') # No thanks undefined ivar warnings
  Hoe.plugin :bundler
  Hoe.spec('tracksperanto') do | p |
    p.readme_file   = 'README.rdoc'
    p.extra_rdoc_files  = FileList['*.rdoc'] + FileList['*.txt']
    p.version = Tracksperanto::VERSION
    
    p.extra_deps = {
      "obuf" => "~> 1.0",
      "flame_channel_parser" => "2.2.1",
      "progressbar" => "~> 0.9",
      "update_hints" => "~> 1.0"
    }
    
    p.extra_dev_deps = {"flexmock" => "~> 0.8", "cli_test" => "~>1.0"}
    
    p.developer('Julik Tarkhanov', 'me@julik.nl')
    p.clean_globs = File.read(File.dirname(__FILE__) + "/.gitignore").split(/\s/).to_a
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


