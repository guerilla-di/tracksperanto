require_relative 'lib/tracksperanto/version'

Gem::Specification.new do |spec|
  spec.name = "tracksperanto"
  spec.version = Tracksperanto::VERSION
  spec.required_ruby_version = '>= 2.1.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end
  
  spec.authors = ["Julik Tarkhanov"]
  spec.date = "2016-07-19"
  spec.description = "Converts 2D track exports between different apps like Flame, MatchMover, PFTrack..."
  spec.email = "me@julik.nl"
  spec.executables = ["tracksperanto"]
  spec.extra_rdoc_files = [
    "README.md"
  ]
  spec.homepage = "http://guerilla-di.org/tracksperanto"
  spec.licenses = ["MIT"]
  spec.require_paths = ["lib"]
  spec.rubygems_version = "1.8.23.2"
  spec.summary = "A universal 2D tracks converter"
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.start_with?("test/import/samples/*/*.*") # Remove the sample files
  end.reject do |f|
    f.start_with? "test/subpixel"
  end
  
  spec.bindir = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_runtime_dependency "obuf", "~> 1.1"
  spec.add_runtime_dependency "tickly", "~> 2.1.6"
  spec.add_runtime_dependency "bychar", "~> 3"
  spec.add_runtime_dependency "progressive_io", "~> 1.0"
  spec.add_runtime_dependency "flame_channel_parser", "~> 4.0"
  # Locked because newer versions require tins that do not work on 1.9.3 and less
  spec.add_runtime_dependency 'term-ansicolor', '<= 1.2.0'
  # flame_channel_parser wants it via framecurve, but for Ruby 1.8.7 we have to ask for an older version
  spec.add_runtime_dependency 'tins', '< 0.9.0'
  spec.add_runtime_dependency "progressbar", "0.10.0"
  spec.add_runtime_dependency "update_hints", "~> 1.0"

  spec.add_development_dependency "bundler", '~> 1'
  spec.add_development_dependency "test-unit", '3.1.5'
  spec.add_development_dependency "approximately"
  spec.add_development_dependency "rake", '~> 10'
  spec.add_development_dependency "linebyline"
  spec.add_development_dependency "flexmock"
  spec.add_development_dependency "cli_test", "~>1.0"
end

