require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class ShakeTextImportTest < Test::Unit::TestCase
  DELTA = 0.000001
  
  def test_introspects_properly
    i = Tracksperanto::Import::ShakeText
    assert_equal "Shake .txt tracker file", i.human_name
    assert !i.autodetects_size?
  end
  
  def test_parsing
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_text/one_shake_tracker.txt')
    trackers = Tracksperanto::Import::ShakeText.new.parse(fixture)
    
    assert_kind_of Enumerable, trackers
    assert_equal 1, trackers.length
    
    t = trackers[0]
    
    assert_kind_of Tracksperanto::Tracker, t
    assert_equal 46, t.keyframes.length
    assert_equal "track1", t.name
    
    second_kf = t.keyframes[1]
    assert_in_delta 121, second_kf.frame, DELTA
    assert_in_delta 373.746, second_kf.abs_x, DELTA
    assert_in_delta 984.564, second_kf.abs_y, DELTA
    assert_in_delta 0.002, second_kf.residual, DELTA
  end
  
  def test_parsing_two_trackers
    fixture = File.open(File.dirname(__FILE__) + '/samples/shake_text/two_shake_trackers.txt')
    trackers = Tracksperanto::Import::ShakeText.new.parse(fixture)
    
    assert_kind_of Enumerable, trackers
    assert_equal 2, trackers.length
    
    t = trackers[0]
    
    assert_equal "track1", t.name
    assert_kind_of Tracksperanto::Tracker, t
    assert_equal 6, t.keyframes.length
    
    second_kf = t.keyframes[1]
    assert_in_delta 111, second_kf.frame, DELTA
    
    t2 = trackers[-1]
    assert_equal "track2", t2.name
  end
end