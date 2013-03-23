# -*- ruby -*-
source :rubygems

gem "bundler"

gem "obuf", "~> 1.1"
gem "tickly", "~> 2.1"
gem "bychar", "~> 2"
gem "progressive_io", "~> 1.0"
gem "flame_channel_parser", "~> 4.0"

gem "progressbar", "0.10.0"
gem "update_hints", "~> 1.0"

group :development do
  gem "approximately"
  gem "jeweler"
  gem "rake"
  
  if RUBY_VERSION > "1.8"
    gem "flexmock", "~> 1.3", :require => %w( flexmock flexmock/test_unit )
  else
    gem "flexmock", "~> 0.8", :require => %w( flexmock flexmock/test_unit )
  end
  
  gem "cli_test", "~>1.0"
  gem "rake-hooks"
  gem "ruby-prof"
end