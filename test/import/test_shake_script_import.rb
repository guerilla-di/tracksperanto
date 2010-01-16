require File.dirname(__FILE__) + '/../helper'

class ShakeScriptImportTest < Test::Unit::TestCase
  DELTA = 0.001
  
  def test_parsing_fifty_tracker_nodes_with_one_track_each
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_script/shake_tracker_nodes.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 50, trackers.length
    
    t = trackers[0]
    assert_equal "Tracker8_track1", t.name
    
    first_kf = t.keyframes[0]
    assert_equal 107, first_kf.frame
    
    assert_in_delta 1065.41, first_kf.abs_y, DELTA
    assert_in_delta 1281.14, first_kf.abs_x, DELTA
    assert_in_delta 1.0, first_kf.residual, DELTA
    
    second_kf = t.keyframes[1]
    assert_in_delta 0.00129, second_kf.residual, DELTA
  end
  
  def test_parse_tracker_node_with_no_animation
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_script/shake_tracker_with_no_anim.shk')
    assert_nothing_raised do
      trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
      assert_equal 0, trackers.length
    end
  end
  
  def test_parsing_two_tracks_in_one_tracker_node
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_script/two_tracks_in_one_tracker.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 2, trackers.length
    
    t = trackers[0]
    assert_equal "Tracker1_track1", t.name
    
    first_kf = t.keyframes[0]
    assert_equal 0, first_kf.frame
    assert_in_delta 716.08, first_kf.abs_x, DELTA
    assert_in_delta 885.123, first_kf.abs_y, DELTA
    assert_in_delta 0.0, first_kf.residual, DELTA
    
    second_kf = t.keyframes[1]
    assert_in_delta 0.00129, second_kf.residual, DELTA
    
    t2 = trackers[1]
    assert_equal "Tracker1_track2", t2.name
    
  end

  def test_parsing_three_tracks_in_one_stabilizer_node
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_script/three_tracks_in_one_stabilizer.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    ft = trackers[0]
    assert_equal "Stabilize1_track1", ft.name
    assert_equal 3, trackers.length
  end
  
  def test_parsing_four_tracks_in_one_stabilizer_node
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_script/four_tracks_in_one_stabilizer.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    ft = trackers[0]
    assert_equal "Stabilize2_track1", ft.name
    assert_equal 4, trackers.length
  end
  
  def test_parsing_four_tracks_in_one_matchmove_node
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_script/four_tracks_in_one_matchmove.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 4, trackers.length
    
    ft = trackers[0]
    assert_equal "MatchMove1_track1", ft.name
  end
  
  def test_parsing_from_nspline_curves
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_script/shake_trackers_with_Nspline.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 3, trackers.length
    assert_equal 160, trackers[0].length
  end
  
  def test_boujou_exported_script
    fixture = File.open(File.dirname(__FILE__) + "/samples/shake_script/shake_script_from_boujou.shk")
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 1, trackers.length
    assert_equal 387, trackers[0].length
  end
  
  def test_hermite_interpolation
    fixture = File.open(File.dirname(__FILE__) + "/samples/shake_script/stabilize_nodes_with_hermite.shk")
    trackers = Tracksperanto::Import::ShakeScript.new.parse(fixture)
    assert_equal 3, trackers.length
    last_t = trackers[-1]
    assert_equal "Stabilize1_track1", last_t.name
    assert_equal 73, last_t.length
    
    last_kf = last_t[-1]
    assert_equal 76, last_kf.frame
    assert_in_delta 1256.72, last_kf.abs_x, DELTA
    assert_in_delta 1569.04, last_kf.abs_y, DELTA
  end
end