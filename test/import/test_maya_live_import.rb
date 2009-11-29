require File.dirname(__FILE__) + '/../helper'

class MayaLiveImportTest < Test::Unit::TestCase
  DELTA = 0.001
  
  def test_introspects_properly
    i = Tracksperanto::Import::MayaLive
    assert_equal "Maya Live track export file", i.human_name
    assert i.autodetects_size?
  end
  
  def test_parse_file
    f = File.open(File.dirname(__FILE__) + "/samples/mayalive/mayalive_kipShot.txt")
    
    p = Tracksperanto::Import::MayaLive.new
    trackers = p.parse(f)
    
    assert_in_delta 2.37, p.aspect, DELTA
    assert_equal 1280, p.width
    assert_equal 540, p.height
    
    assert_equal 18, trackers.length
    
    first_t = trackers[0]
    assert_equal "trackedPoint1", first_t.name
    assert_equal 225, first_t.length
    first_kf = first_t[0]
    
    assert_equal 0, first_kf.frame
    assert_in_delta 388.542, first_kf.abs_x, DELTA
    assert_in_delta 513.346, first_kf.abs_y, DELTA
  end
  
  def test_parse_file_with_custom_aspect
    f = File.open(File.dirname(__FILE__) + "/samples/mayalive/mayalive_kipShot.txt")
    
    p = Tracksperanto::Import::MayaLive.new
    p.aspect = 1.78
    trackers = p.parse(f)
    assert_in_delta 1.78, p.aspect, DELTA
    
    assert_equal 1280, p.width
    assert_equal 540, p.height
    
    assert_equal 18, trackers.length
    
    first_t = trackers[0]
    assert_equal "trackedPoint1", first_t.name
    assert_equal 225, first_t.length
    first_kf = first_t[0]
    
    assert_equal 0, first_kf.frame
    assert_in_delta 305.141, first_kf.abs_x, DELTA
    assert_in_delta 513.346, first_kf.abs_y, DELTA
  end
end