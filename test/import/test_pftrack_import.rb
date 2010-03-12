require File.dirname(__FILE__) + '/../helper'

class PFTrackImportTest < Test::Unit::TestCase
  DELTA = 0.1 
  
  def test_introspects_properly
    i = Tracksperanto::Import::PFTrack
    assert_equal "PFTrack .2dt file", i.human_name
    assert !i.autodetects_size?
  end
  
  def test_parsing_from_pftrack5_with_digit_names
    fixture = File.open(File.dirname(__FILE__) + '/samples/pftrack5/apft.2dt')
    parser = Tracksperanto::Import::PFTrack.new(:width => 1920, :height => 1080)
    
    trackers = parser.parse(fixture)
    assert_equal 4, trackers.length
    second_tracker = trackers[1]
    assert_equal "1015", second_tracker.name
  end
  
  def test_parsing_from_importable_pftrack_4
    
    fixture = File.open(File.dirname(__FILE__) + '/samples/pftrack4/sourcefile_pftrack.2dt')
    
    parser = Tracksperanto::Import::PFTrack.new
    parser.width = 2560
    parser.height = 1080
    
    trackers = parser.parse(fixture)
    assert_equal 43, trackers.length
    
    first_kf = trackers[0].keyframes[0]
    last_kf = trackers[0].keyframes[-1]
    
    assert_equal "Tracker1", trackers[0].name
    assert_equal 341, trackers[0].keyframes.length
    
    assert_equal 41, first_kf.frame
    assert_in_delta 984.611, first_kf.abs_x, DELTA
    assert_in_delta 30.220, first_kf.abs_y, DELTA
    assert_in_delta 0.0, first_kf.residual, DELTA
    
    last_kf = trackers[0].keyframes[-1]
    assert_in_delta 729.330, last_kf.abs_x, DELTA
    
    assert_equal "Tracker41", trackers[-1].name
    assert_equal 467, trackers[-1].keyframes.length
  end
  
  def test_garage_shot_from_pftrack_5
    fixture = File.open(File.dirname(__FILE__) + '/samples/pftrack5/garage.2dt')
    parser = Tracksperanto::Import::PFTrack.new(:width => 1920, :height => 1080)
    trackers = parser.parse(fixture)
    assert_equal 250, trackers.length
    assert_equal "Tracker121", trackers[0].name
    assert_equal 189, trackers[0].length
  end
  
end