require File.dirname(__FILE__) + '/../helper'

class ShakeScriptImportTest < Test::Unit::TestCase
  DELTA = 0.001
  
  def test_parsing_many_tracker_noes_with_one_track_each
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_tracker_nodes.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 50, trackers.length
    
    t = trackers[0]
    assert_equal "track1", t.name
    
    first_kf = t.keyframes[0]
    assert_equal 0, first_kf.frame
    assert_in_delta 886.212, first_kf.abs_y, DELTA
    assert_in_delta 715.839, first_kf.abs_x, DELTA
    assert_in_delta 0.0, first_kf.residual, DELTA
    
    second_kf = t.keyframes[1]
    assert_in_delta 0.00129, second_kf.residual, DELTA
  end

  def test_parsing_many_tracks_in_one_tracker_node
    fixture = File.open(File.dirname(__FILE__) + '/samples/two_tracks_in_one_tracker.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 2, trackers.length
    
    t = trackers[0]
    assert_equal "track1", t.name
    
    first_kf = t.keyframes[0]
    assert_equal 0, first_kf.frame
    assert_in_delta 716.08, first_kf.abs_x, DELTA
    assert_in_delta 885.123, first_kf.abs_y, DELTA
    assert_in_delta 0.0, first_kf.residual, DELTA
    
    second_kf = t.keyframes[1]
    assert_in_delta 0.00129, second_kf.residual, DELTA
    
    t2 = trackers[1]
    assert_equal "track2", t2.name
    
  end

  def test_parsing_many_tracks_in_one_stabilizer_node
    fixture = File.open(File.dirname(__FILE__) + '/samples/three_tracks_in_one_stabilizer.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 3, trackers.length
  end
end