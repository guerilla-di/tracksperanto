# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tracksperanto}
  s.version = "2.8.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Julik Tarkhanov}]
  s.date = %q{2011-11-20}
  s.description = %q{Converts 2D track exports between different apps like Flame, MatchMover, PFTrack...}
  s.email = %q{me@julik.nl}
  s.executables = [%q{tracksperanto}]
  s.extra_rdoc_files = [
    "DEVELOPER_DOCS.rdoc",
    "README.rdoc"
  ]
  s.files = [
    "DEVELOPER_DOCS.rdoc",
    "Gemfile",
    "History.txt",
    "MIT_LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "bin/tracksperanto",
    "lib/export/base.rb",
    "lib/export/boujou.rb",
    "lib/export/equalizer3.rb",
    "lib/export/equalizer4.rb",
    "lib/export/flame_stabilizer.rb",
    "lib/export/flame_stabilizer_cornerpin.rb",
    "lib/export/match_mover.rb",
    "lib/export/maya_live.rb",
    "lib/export/mux.rb",
    "lib/export/nuke_script.rb",
    "lib/export/pfmatchit.rb",
    "lib/export/pftrack.rb",
    "lib/export/pftrack_5.rb",
    "lib/export/shake_text.rb",
    "lib/export/syntheyes.rb",
    "lib/import/base.rb",
    "lib/import/boujou.rb",
    "lib/import/equalizer3.rb",
    "lib/import/equalizer4.rb",
    "lib/import/flame_stabilizer.rb",
    "lib/import/match_mover.rb",
    "lib/import/maya_live.rb",
    "lib/import/nuke_grammar/utils.rb",
    "lib/import/nuke_script.rb",
    "lib/import/pftrack.rb",
    "lib/import/shake_grammar/catcher.rb",
    "lib/import/shake_grammar/lexer.rb",
    "lib/import/shake_script.rb",
    "lib/import/shake_text.rb",
    "lib/import/syntheyes.rb",
    "lib/middleware/base.rb",
    "lib/middleware/flip.rb",
    "lib/middleware/flop.rb",
    "lib/middleware/golden.rb",
    "lib/middleware/length_cutoff.rb",
    "lib/middleware/lerp.rb",
    "lib/middleware/lint.rb",
    "lib/middleware/prefix.rb",
    "lib/middleware/reformat.rb",
    "lib/middleware/scaler.rb",
    "lib/middleware/shift.rb",
    "lib/middleware/slipper.rb",
    "lib/middleware/start_trim.rb",
    "lib/pipeline/base.rb",
    "lib/tracksperanto.rb",
    "lib/tracksperanto/block_init.rb",
    "lib/tracksperanto/buffer_io.rb",
    "lib/tracksperanto/buffering_reader.rb",
    "lib/tracksperanto/casts.rb",
    "lib/tracksperanto/const_name.rb",
    "lib/tracksperanto/ext_io.rb",
    "lib/tracksperanto/flame_builder.rb",
    "lib/tracksperanto/format_detector.rb",
    "lib/tracksperanto/keyframe.rb",
    "lib/tracksperanto/returning.rb",
    "lib/tracksperanto/safety.rb",
    "lib/tracksperanto/simple_export.rb",
    "lib/tracksperanto/tracker.rb",
    "lib/tracksperanto/uv_coordinates.rb",
    "lib/tracksperanto/zip_tuples.rb",
    "test/export/README_EXPORT_TESTS.txt",
    "test/export/samples/ref_Mayalive.txt",
    "test/export/samples/ref_Mayalive_CustomAspect.txt",
    "test/export/samples/ref_NukeScript.nk",
    "test/export/samples/ref_PFMatchit.2dt",
    "test/export/samples/ref_PFTrack.2dt",
    "test/export/samples/ref_PFTrack5.2dt",
    "test/export/samples/ref_ShakeText.txt",
    "test/export/samples/ref_Syntheyes.txt",
    "test/export/samples/ref_boujou.txt",
    "test/export/samples/ref_equalizer.txt",
    "test/export/samples/ref_equalizer3.txt",
    "test/export/samples/ref_flame.stabilizer",
    "test/export/samples/ref_flameCornerpin.stabilizer",
    "test/export/samples/ref_matchmover.rz2",
    "test/export/test_boujou_export.rb",
    "test/export/test_equalizer3_export.rb",
    "test/export/test_equalizer_export.rb",
    "test/export/test_flame_stabilizer_cornerpin_export.rb",
    "test/export/test_flame_stabilizer_export.rb",
    "test/export/test_match_mover_export.rb",
    "test/export/test_maya_live_export.rb",
    "test/export/test_mux.rb",
    "test/export/test_nuke_export.rb",
    "test/export/test_pfmatchit_export.rb",
    "test/export/test_pftrack5_export.rb",
    "test/export/test_pftrack_export.rb",
    "test/export/test_shake_export.rb",
    "test/export/test_syntheyes_export.rb",
    "test/helper.rb",
    "test/import/README_SAMPLES.txt",
    "test/import/test_3de_import.rb",
    "test/import/test_3de_import3.rb",
    "test/import/test_boujou_import.rb",
    "test/import/test_flame_import.rb",
    "test/import/test_match_mover_import.rb",
    "test/import/test_maya_live_import.rb",
    "test/import/test_nuke_import.rb",
    "test/import/test_pftrack_import.rb",
    "test/import/test_shake_catcher.rb",
    "test/import/test_shake_lexer.rb",
    "test/import/test_shake_script_import.rb",
    "test/import/test_shake_text_import.rb",
    "test/import/test_syntheyes_import.rb",
    "test/middleware/test_flip_middleware.rb",
    "test/middleware/test_flop_middleware.rb",
    "test/middleware/test_golden_middleware.rb",
    "test/middleware/test_length_cutoff_middleware.rb",
    "test/middleware/test_lerp_middleware.rb",
    "test/middleware/test_lint_middleware.rb",
    "test/middleware/test_prefix.rb",
    "test/middleware/test_reformat_middleware.rb",
    "test/middleware/test_scaler_middleware.rb",
    "test/middleware/test_shift_middleware.rb",
    "test/middleware/test_slip_middleware.rb",
    "test/middleware/test_start_trim_middleware.rb",
    "test/test_buffer_io.rb",
    "test/test_bufferingreader.rb",
    "test/test_cli.rb",
    "test/test_const_name.rb",
    "test/test_extio.rb",
    "test/test_flame_builder.rb",
    "test/test_format_detector.rb",
    "test/test_keyframe.rb",
    "test/test_pipeline.rb",
    "test/test_simple_export.rb",
    "test/test_tracker.rb",
    "test/test_tracksperanto.rb",
    "tracksperanto.gemspec"
  ]
  s.homepage = %q{http://guerilla-di.org/tracksperanto}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{A universal 2D tracks converter}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tracksperanto>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_runtime_dependency(%q<obuf>, ["~> 1.0.1"])
      s.add_runtime_dependency(%q<progressive_io>, ["~> 1.0"])
      s.add_runtime_dependency(%q<flame_channel_parser>, ["~> 3.0"])
      s.add_runtime_dependency(%q<progressbar>, ["~> 0.9"])
      s.add_runtime_dependency(%q<update_hints>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<cli_test>, ["~> 1.0"])
    else
      s.add_dependency(%q<tracksperanto>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<cli_test>, ["~> 1.0"])
      s.add_dependency(%q<obuf>, ["~> 1.0.1"])
      s.add_dependency(%q<progressive_io>, ["~> 1.0"])
      s.add_dependency(%q<flame_channel_parser>, ["~> 3.0"])
      s.add_dependency(%q<progressbar>, ["~> 0.9"])
      s.add_dependency(%q<update_hints>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<cli_test>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<tracksperanto>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<cli_test>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<cli_test>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<cli_test>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<cli_test>, ["~> 1.0"])
    s.add_dependency(%q<obuf>, ["~> 1.0.1"])
    s.add_dependency(%q<progressive_io>, ["~> 1.0"])
    s.add_dependency(%q<flame_channel_parser>, ["~> 3.0"])
    s.add_dependency(%q<progressbar>, ["~> 0.9"])
    s.add_dependency(%q<update_hints>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<cli_test>, ["~> 1.0"])
  end
end

