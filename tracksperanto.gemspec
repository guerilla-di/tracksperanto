# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tracksperanto}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julik Tarkhanov"]
  s.date = %q{2009-09-13}
  s.default_executable = %q{tracksperanto}
  s.description = %q{Tracksperanto is a universal 2D-track translator between many apps.  Import support: * Flame .stabilizer file (not the .stabilizer.p blob format) * Nuke script (Tracker3 nodes, also known as Tracker) * Shake script (one track per Tracker node, no support for Matchmove or Stabilize) * Shake tracker node export (textfile with many tracks per file), also exported by Boujou and others. * PFTrack 2dt files * Syntheyes 2D tracking data exports (UV coordinates)  Export support:  * Shake text file (many trackers per file), also accepted by Boujou. May crash Shake with more than 4-5 tracks. * PFTrack 2dt file (with residuals) * Syntheyes 2D tracking data import (UV coordinates)  The main way to use Tracksperanto is to use the supplied "tracksperanto" binary, like so:  tracksperanto -f ShakeScript -w 1920 -h 1080 /Films/Blockbuster/Shots/001/script.shk  ShakeScript is the name of the translator that will be used to read the file (many apps export tracks as .txt files so there is no way for us to autodetect them all). -w and -h stand for Width and Height and define the size of your comp (different tracking apps use different coordinate systems and we need to know the size of the comp to properly convert these). You also have additional options like -xs, -ys and --slip - consult the usage info for the tracksperanto binary.  The converted files will be saved in the same directory as the source, if resulting converted files already exist ++they will be overwritten without warning++.}
  s.email = ["me@julik.nl"]
  s.executables = ["tracksperanto"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = [".DS_Store", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/tracksperanto", "lib/.DS_Store", "lib/export/base.rb", "lib/export/mux.rb", "lib/export/pftrack.rb", "lib/export/shake_text.rb", "lib/export/syntheyes.rb", "lib/import/base.rb", "lib/import/flame_stabilizer.rb", "lib/import/nuke_script.rb", "lib/import/pftrack.rb", "lib/import/shake_script.rb", "lib/import/shake_text.rb", "lib/import/syntheyes.rb", "lib/middleware/base.rb", "lib/middleware/golden.rb", "lib/middleware/reformat.rb", "lib/middleware/scaler.rb", "lib/middleware/slipper.rb", "lib/pipeline/base.rb", "lib/tracksperanto.rb", "test/.DS_Store", "test/export/README_EXPORT_TESTS.txt", "test/export/samples/ref_PFTrack.2dt", "test/export/samples/ref_ShakeText.txt", "test/export/test_pftrack_export.rb", "test/export/test_shake_export.rb", "test/helper.rb", "test/import/samples/.DS_Store", "test/import/samples/flyover2DP_syntheyes.txt", "test/import/samples/fromCombustion_fromMidClip_wSnap.stabilizer", "test/import/samples/hugeFlameSetup.stabilizer", "test/import/samples/megaTrack.action.3dtrack.stabilizer", "test/import/samples/one_shake_tracker.txt", "test/import/samples/one_shake_tracker_from_first.txt", "test/import/samples/one_tracker_with_break.nk", "test/import/samples/one_tracker_with_break_in_grp.nk", "test/import/samples/shake_tracker_nodes.shk", "test/import/samples/shake_tracker_nodes_to_syntheyes.txt", "test/import/samples/sourcefile_pftrack.2dt", "test/import/samples/three_tracks_in_one_stabilizer.shk", "test/import/samples/two_shake_trackers.txt", "test/import/samples/two_tracks_in_one_tracker.shk", "test/import/test_flame_import.rb", "test/import/test_nuke_import.rb", "test/import/test_pftrack_import.rb", "test/import/test_shake_script_import.rb", "test/import/test_shake_text_import.rb", "test/import/test_syntheyes_import.rb", "test/middleware/test_golden_middleware.rb", "test/middleware/test_reformat_middleware.rb", "test/middleware/test_scaler_middleware.rb", "test/middleware/test_slip_middleware.rb", "test/test_keyframe.rb", "tracksperanto.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://guerilla-di.org/tracksperanto}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{guerilla-di}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Tracksperanto is a universal 2D-track translator between many apps}
  s.test_files = ["test/export/test_pftrack_export.rb", "test/export/test_shake_export.rb", "test/import/test_flame_import.rb", "test/import/test_nuke_import.rb", "test/import/test_pftrack_import.rb", "test/import/test_shake_script_import.rb", "test/import/test_shake_text_import.rb", "test/import/test_syntheyes_import.rb", "test/middleware/test_golden_middleware.rb", "test/middleware/test_reformat_middleware.rb", "test/middleware/test_scaler_middleware.rb", "test/middleware/test_slip_middleware.rb", "test/test_keyframe.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<flexmock>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<flexmock>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<flexmock>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
