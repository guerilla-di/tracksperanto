require 'rubygems'
require 'hoe'
require './lib/tracksperanto'


# Disable spurious warnings when running tests, ActiveMagic cannot stand -w
Hoe::RUBY_FLAGS.replace ENV['RUBY_FLAGS'] || "-I#{%w(lib test).join(File::PATH_SEPARATOR)}" + 
  (Hoe::RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')
  
Hoe.spec('tracksperanto') do | p |
  p.version = Tracksperanto::VERSION
  p.dependencies << "flexmock"
  p.rubyforge_name = 'guerilla-di'
  p.developer('Julik Tarkhanov', 'me@julik.nl')
  p.extra_rdoc_files = p.extra_rdoc_files.reject{|e| e =~ "samples\/"}
end