# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class MatchMoverImportTest < Test::Unit::TestCase
  DELTA = 0.01
  
  P = File.dirname(__FILE__) + '/samples/match_mover/kipPointsMatchmover.rz2'
  P2 = File.dirname(__FILE__) + '/samples/match_mover/NonSequentialMatchmoverPoints.rz2'
  P3 = File.dirname(__FILE__) + '/samples/match_mover/cha_171_1020_atb_v001.rz2'
  
  def test_introspects_properly
    i = Tracksperanto::Import::MatchMover
    assert_equal "MatchMover REALVIZ Ascii Point Tracks .rz2 file", i.human_name
    assert i.autodetects_size?
  end
  
  def test_parsing_with_non_sequential_keyframes
    fixture = File.open(P2)
    
    parser = Tracksperanto::Import::MatchMover.new(:io => fixture)
    trackers = parser.to_a
    assert_not_equal 0, trackers[0].length
    assert_equal 0, trackers[0][0].frame, "Should have offset the first frame to 0"
  end
  
  def test_parsing_case_nil_exception
    fixture = File.open(P3)
    
    parser = Tracksperanto::Import::MatchMover.new(:io => fixture)
    trackers = parser.to_a
    assert_equal 6, trackers.length
  end
  
  def test_parsing_from_matchmover
    fixture = File.open(P)
    
    parser = Tracksperanto::Import::MatchMover.new(:io => fixture)
    trackers = parser.to_a
    
    assert_equal 2560, parser.width
    assert_equal 1080, parser.height
    
    assert_equal 5, trackers.length
    
    first_t = trackers[0]
    assert_equal "Track_01", first_t.name
    assert_equal 131, first_t.length
    first_kf = first_t[0]
    
    assert_equal 0, first_kf.frame
    assert_in_delta 649.523, first_kf.abs_x, DELTA 
    assert_in_delta 656.071, first_kf.abs_y, DELTA
    assert_in_delta 0.2, first_kf.residual, DELTA
    
    last_kf = first_t[-1]
    assert_equal 130, last_kf.frame
    assert_in_delta 603.148, last_kf.abs_x, DELTA 
    assert_in_delta 351.54, last_kf.abs_y, DELTA
    assert_in_delta 0.027457, last_kf.residual, DELTA
  end
  
end
