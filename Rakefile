require 'rubygems'
require 'hoe'
require './lib/tracksperanto'


# Disable spurious warnings when running tests, ActiveMagic cannot stand -w
Hoe::RUBY_FLAGS.replace ENV['RUBY_FLAGS'] || "-I#{%w(lib test).join(File::PATH_SEPARATOR)}" + 
  (Hoe::RUBY_DEBUG ? " #{RUBY_DEBUG}" : '')
  
Hoe.new('tracksperanto', Tracksperanto::VERSION) do |p|
  p.rubyforge_name = 'guerilla-di'
  p.developer('Julik Tarkhanov', 'me@julik.nl')
end