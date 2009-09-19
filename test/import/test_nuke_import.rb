require File.dirname(__FILE__) + '/../helper'

class NukeImportTest < Test::Unit::TestCase
  DELTA = 0.1 
  
  def test_introspects_properly
    i = Tracksperanto::Import::NukeScript
    assert_equal "Nuke .nk script file", i.human_name
    assert !i.autodetects_size?
  end
  
  def test_parsing_from_nuke
    fixture = File.open(File.dirname(__FILE__) + '/samples/one_tracker_with_break.nk')
    
    parser = Tracksperanto::Import::NukeScript.new
    parser.width = 2048
    parser.height = 1176
    
    trackers = parser.parse(fixture)
    
    assert_equal 2, trackers.length
    sec_tracker = trackers[1]
    assert_equal 22, sec_tracker.keyframes.length
    assert_equal 762, sec_tracker.keyframes[-1].frame
    assert_in_delta 1147.972, sec_tracker.keyframes[-1].abs_x, DELTA
    assert_in_delta 510.107, sec_tracker.keyframes[-1].abs_y, DELTA
  end
  
  def test_parsing_from_nuke_group
    fixture = File.open(File.dirname(__FILE__) + '/samples/one_tracker_with_break_in_grp.nk')
    
    parser = Tracksperanto::Import::NukeScript.new
    parser.width = 2048
    parser.height = 1176
    
    trackers = parser.parse(fixture)
    assert_equal 2, trackers.length
    
    sec_tracker = trackers[1]
    assert_equal 22, sec_tracker.keyframes.length
    assert_equal 762, sec_tracker.keyframes[-1].frame
    assert_in_delta 1147.972, sec_tracker.keyframes[-1].abs_x, DELTA
    assert_in_delta 510.107, sec_tracker.keyframes[-1].abs_y, DELTA
  end
  
  def test_parsing_nuke_curve
    curve = '{curve x742 888 890.2463989 891.6602783 \
893.5056763 895.6155396 s95 897.2791748 899.1762695 x754 912.0731812 x755 913.7190552 916.0959473 918.1025391 920.0751953 922.1898804}'
    p = Tracksperanto::Import::NukeScript.new
    result = p.send(:parse_curve, curve)
    assert_kind_of Array, result
    assert_equal 13, result.length
    assert_equal 742, result[0][0]
    assert_equal 754, result[7][0]
  end
  
  def test_zip_channels
    tuples_x = [[1, 125], [3, 234], [5, 456], [9,876]]
    tuples_y = [[2, 437], [3, 123], [6, 432], [9, 430]]
    result = Tracksperanto::Import::NukeScript.new.send(:zip_curve_tuples, tuples_x, tuples_y)
    assert_equal [[3, 234, 123], [9, 876, 430]], result
  end
end