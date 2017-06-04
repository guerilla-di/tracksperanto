require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class MatchMoverRZMLImportTest < Test::Unit::TestCase
  DELTA = 0.1
  
  P = File.dirname(__FILE__) + '/samples/match_mover_rzml/md_145_1070_right_t1.rzml'

  def test_introspects_properly
    i = Tracksperanto::Import::MatchMoverRZML
    assert_equal "MatchMover RZML .rzml file", i.human_name
    assert i.autodetects_size?
  end
  
  def test_parsing_from_matchmover
    fixture = File.open(P)
    
    parser = Tracksperanto::Import::MatchMoverRZML.new(:io => fixture)
    trackers = parser.to_a
    
    assert_equal 2048, parser.width
    assert_equal 1152, parser.height
    
    assert_equal 2, trackers.length
    t = trackers[0]
    
    assert_equal 0, trackers[0][0].frame
    assert_equal 1, trackers[0][1].frame
    
    assert_in_delta 626.7, trackers[0][0].abs_x, DELTA
    assert_in_delta 663.4, trackers[0][0].abs_y, DELTA
  end
  
end
