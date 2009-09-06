require File.dirname(__FILE__) + '/helper'

class SyntheyesImportTest < Test::Unit::TestCase
  DELTA = 0.1 
  
  def test_parsing_from_importable
    fixture = File.read(File.dirname(__FILE__) + '/samples/sourcefile_pftrack.2dt')

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
    assert_equal 467, tracker[-1].name
  end
end