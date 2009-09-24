require File.dirname(__FILE__) + '/../helper'

class MatchMoverImportTest < Test::Unit::TestCase
  DELTA = 0.01
  
  P = File.dirname(__FILE__) + '/samples/kipPointsMatchmover.rz2'
  
  def test_introspects_properly
    i = Tracksperanto::Import::MatchMover
    assert_equal "MatchMover .rz2 file", i.human_name
    assert i.autodetects_size?
  end
  
  def test_parsing_from_matchmover
    fixture = File.open(P)
    
    parser = Tracksperanto::Import::MatchMover.new
    parser.width = 2048
    parser.height = 1176
    
    trackers = parser.parse(fixture)
    assert_equal 2560, parser.width
    assert_equal 1080, parser.height
    
    assert_equal 5, trackers.length
    
    first_t = trackers[0]
    assert_equal "Track_01", first_t.name
    assert_equal 131, first_t.length
    first_kf = first_t[0]
    
    assert_equal 0, first_kf.frame
    assert_in_delta 649.523, first_kf.abs_x, DELTA 
    assert_in_delta 423.929, first_kf.abs_y, DELTA
    assert_in_delta 0.2, first_kf.residual, DELTA
    
    last_kf = first_t[-1]
    assert_equal 130, last_kf.frame
    assert_in_delta 603.148, last_kf.abs_x, DELTA 
    assert_in_delta 728.46, last_kf.abs_y, DELTA
    assert_in_delta 0.027457, last_kf.residual, DELTA
  end
  
end