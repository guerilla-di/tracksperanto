require "bundler/gem_tasks"
require 'rake/testtask'

desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

# Automatically update the supported format list
task :update_readme do
  require File.dirname(__FILE__) + '/lib/tracksperanto'
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

task :update_license_date do
  license_path = File.dirname(__FILE__) + "/MIT_LICENSE.txt"
  license_text = File.read(license_path)
  license_text.gsub!(/2009\-(\d+)/, "2009-#{Time.now.year + 1}")
  File.open(license_path, "w"){|f| f << license_text }
end

# Automatically update the LICENSE
Rake::Task[:test].enhance [:update_license_date, :update_readme]
task :default => [ :test ]

