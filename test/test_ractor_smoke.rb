require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestRactorSmoke < Test::Unit::TestCase
  SAMPLES = {
    "3de_v3/3de_export_v3.txt" => "Equalizer3",
    "3de_v4/3de_export_cube.txt" => "Equalizer4",
    "boujou_features_text/boujou_txt_export.txt" => "Boujou",
    "flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer" => "FlameStabilizer",
    "flame_stabilizer/stabilizer_2014_stp.stabilizer" => "FlameStabilizer",
    "match_mover/kipPointsMatchmover.rz2" => "MatchMover",
    "match_mover_rzml/md_145_1070_right_t1.rzml" => "MatchMoverRZML",
    "mayalive/mayalive_kipShot.txt" => "MayaLive",
    "nuke/nuke8_tracker4_copypastes.nk" => "NukeScript",
    "nuke/nuke7_planar.nk" => "NukeScript",
    "pfmatchit/pfmatchit_example.2dt" => "PFTrack",
    "pftrack5/apft.2dt" => "PFTrack",
    "shake_script/four_tracks_in_one_stabilizer.shk" => "ShakeScript",
    "shake_text/two_shake_trackers.txt" => "ShakeText",
    "syntheyes_2d_paths/cola_plate.txt" => "Syntheyes",
    "syntheyes_all_tracker_paths/shot06_2dTracks.txt" => "SyntheyesAllTrackerPaths",
  }
  TOOLS = [["Shift", {:x_shift => 2}], ["Crop", {:top => 2}], ["Scaler", {:x_factor => 2}]]

  def self.convert(sample_path, importer_name, tools)
    Dir.mktmpdir do |dir|
      input_path = File.join(dir, File.basename(sample_path))
      FileUtils.cp(sample_path, input_path)
      pipeline = Tracksperanto::Pipeline::Base.new(:tool_tuples => tools)
      points, keyframes = pipeline.run(input_path, :importer => importer_name, :width => 1920, :height => 1080)
      outputs = (Dir.entries(dir) - [".", "..", File.basename(input_path)]).sort
      empty_outputs = outputs.select { |name| File.size(File.join(dir, name)).zero? }
      [points, keyframes, outputs, empty_outputs]
    end
  end

  def test_imports_and_exports_inside_ractors
    # On 3.x `Tempfile.new` can't be used from a non-main Ractor, and we need it for Obuf
    omit "Needs Ruby 4.0+ Ractors" unless defined?(Ractor) && Ractor.method_defined?(:value)

    samples_dir = File.dirname(__FILE__) + "/import/samples"
    experimental_warnings, Warning[:experimental] = Warning[:experimental], false
    begin
      ractors = SAMPLES.map do |sample, importer_name|
        ractor = Ractor.new(File.join(samples_dir, sample), importer_name, TOOLS) do |path, imp, tools|
          TestRactorSmoke.convert(path, imp, tools)
        end
        [sample, importer_name, ractor]
      end

      ractors.each do |sample, importer_name, ractor|
        points, keyframes, outputs, empty_outputs = ractor.value
        expected = self.class.convert(File.join(samples_dir, sample), importer_name, TOOLS)

        assert_operator points, :>, 0, "#{sample} should yield trackers"
        assert_equal expected, [points, keyframes, outputs, empty_outputs], "#{sample} should convert the same way as on the main Ractor"
        assert_equal Tracksperanto.exporters.length, outputs.length
        assert_empty empty_outputs
      end
    ensure
      Warning[:experimental] = experimental_warnings
    end
  end
end
