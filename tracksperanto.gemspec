(in /Code/apps/tracksperanto)
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tracksperanto}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julik"]
  s.date = %q{2009-04-19}
  s.default_executable = %q{tracksperanto}
  s.description = %q{}
  s.email = ["me@julik.nl"]
  s.executables = ["tracksperanto"]
  s.extra_rdoc_files = ["Manifest.txt", "README.txt", "test/samples/flyover2DP_syntheyes.txt", "test/samples/one_shake_tracker.txt", "test/samples/one_shake_tracker_from_first.txt", "test/samples/shake_tracker_nodes_to_syntheyes.txt", "test/samples/two_shake_trackers.txt"]
  s.files = ["Manifest.txt", "README.txt", "Rakefile", "bin/tracksperanto", "lib/export/base.rb", "lib/export/flame_stabilizer.rb", "lib/export/mux.rb", "lib/export/pftrack.rb", "lib/export/shake_text.rb", "lib/export/syntheyes.rb", "lib/import/base.rb", "lib/import/flame_stabilizer.rb", "lib/import/shake_script.rb", "lib/import/shake_text.rb", "lib/import/syntheyes.rb", "lib/middleware/base.rb", "lib/middleware/scaler.rb", "lib/middleware/slipper.rb", "lib/pipeline.rb", "lib/tracksperanto.rb", "test/.DS_Store", "test/helper.rb", "test/samples/.DS_Store", "test/samples/flyover2DP_syntheyes.txt", "test/samples/megaTrack.action.3dtrack.stabilizer", "test/samples/one_shake_tracker.txt", "test/samples/one_shake_tracker_from_first.txt", "test/samples/shake_tracker_nodes.shk", "test/samples/shake_tracker_nodes_to_syntheyes.txt", "test/samples/three_tracks_in_one_stabilizer.shk", "test/samples/two_shake_trackers.txt", "test/samples/two_tracks_in_one_tracker.shk", "test/test_keyframe.rb", "test/test_shake_export.rb", "test/test_shake_script_import.rb", "test/test_shake_text_import.rb", "test/test_syntheyes_import.rb"]
  s.has_rdoc = true
  s.homepage = %q{Tracksperanto is a universal 2D-track translator between many apps.}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{guerilla-di}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{}
  s.test_files = ["test/test_keyframe.rb", "test/test_shake_export.rb", "test/test_shake_script_import.rb", "test/test_shake_text_import.rb", "test/test_syntheyes_import.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end
