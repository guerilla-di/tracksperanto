require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class SyntheyesAllPathsImportTest < Test::Unit::TestCase
  DELTA = 0.001 # our SynthEyes sample is somewhat inaccurate :-P
  
  def test_introspects_properly
    i = Tracksperanto::Import::SyntheyesAllTrackerPaths
    assert_equal "Syntheyes \"All Tracker Paths\" export .txt file", i.human_name
    assert !i.autodetects_size?
    assert_not_nil i.known_snags
    assert !i.known_snags.empty?
  end
  
  def test_parsing_from_importable
    fixture = File.open(File.dirname(__FILE__) + '/samples/syntheyes_all_tracker_paths/shot06_2dTracks.txt')
    trackers = Tracksperanto::Import::SyntheyesAllTrackerPaths.new(:io => fixture, :width => 2560, :height => 1080).to_a
    assert_equal 139, trackers.length
    assert_equal "Tracker2_", trackers[0].name
    assert_equal "Tracker3_", trackers[1].name
    assert_equal 44, trackers[0].length
    
    first_kf = trackers[0].at_frame(0)
    assert_in_delta 760.632, first_kf.abs_x, DELTA
    assert_in_delta 760.0, first_kf.abs_y, DELTA
  end
end
