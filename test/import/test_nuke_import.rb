# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class NukeImportTest < Test::Unit::TestCase
  DELTA = 0.01 
  
  def test_introspects_properly
    i = Tracksperanto::Import::NukeScript
    assert_equal "Nuke .nk script file with Tracker or Reconcile3D nodes", i.human_name
    assert !i.autodetects_size?
  end
  
  def test_parsing_big_file_from_nuke
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/45trackers.nk')
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 1176
    
    trackers = parser.to_a
    assert_equal 45, trackers.length
  end
  
  
  def test_parsing_from_reconciles
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/reconciles.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 1176
    
    trackers = parser.to_a.reject{|e| e.empty? }
    
    assert_equal 5, trackers.length
    assert_equal 128, trackers[0].length
  end
  
  def test_parsing_planar_tracker
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/planar.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 4096
    parser.height = 2304
    
    trackers = parser.to_a
    assert_equal 4, trackers.length
    
    ref_names = %w( PlanarTracker2_outputBottomLeft PlanarTracker2_outputBottomRight 
      PlanarTracker2_outputTopRight PlanarTracker2_outputTopLeft )
    assert_equal ref_names, trackers.map{|e| e.name }
  end
  
  def test_parsing_from_nuke
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/one_tracker_with_break.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 1176
    
    trackers = parser.to_a
    
    assert_equal 2, trackers.length
    sec_tracker = trackers[1]
    assert_equal 22, sec_tracker.keyframes.length
    assert_equal 762, sec_tracker.keyframes[-1].frame
    assert_in_delta 1147.972, sec_tracker.keyframes[-1].abs_x, DELTA
    assert_in_delta 510.107, sec_tracker.keyframes[-1].abs_y, DELTA
  end
  
  def test_parsing_many_tracks_per_node
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/018.nk')
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 1920
    parser.height = 1080
    trackers = parser.to_a
    
    assert_equal 21, trackers.length
  end
  
  def test_parsing_node_with_gaps
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/tracker_with_differing_gaps.nk')
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 3112
    
    trackers = parser.to_a
    assert_equal 1, trackers.length
    t = trackers[0]
    assert_equal 45, t.length
    assert_equal 21, t[0].frame
    assert_equal 45, t[24].frame
    assert_equal 60, t[25].frame
    assert_equal 61, t[26].frame
    assert_equal 109, t[-1].frame
  end
  
  def test_parsing_node_with_succesive_gaps_larger_than_one_frame
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/tracker_with_repeating_gaps.nk')
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 1556
    trackers = parser.to_a
    assert_equal 1, trackers.length
    t = trackers[0]
    assert_equal 5, t[3].frame
    assert_equal 8, t[4].frame
    assert_equal 11, t[5].frame
  end
  
  def test_parsing_from_nuke_group
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/one_tracker_with_break_in_grp.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 1176
    
    trackers = parser.to_a
    assert_equal 2, trackers.length
    
    sec_tracker = trackers[1]
    assert_equal 22, sec_tracker.keyframes.length
    assert_equal 762, sec_tracker.keyframes[-1].frame
    assert_in_delta 1147.972, sec_tracker.keyframes[-1].abs_x, DELTA
    assert_in_delta 510.107, sec_tracker.keyframes[-1].abs_y, DELTA
  end
  
  def test_parsing_nuke_curve
    curve = '{curve x742 888 890.2463989 891.6602783 \
893.5056763 895.6155396 s95 897.2791748 899.1762695 \
x754 912.0731812 x755 913.7190552 916.0959473 918.1025391 920.0751953 922.1898804}'
    p = Tracksperanto::NukeGrammarUtils.new
    result = p.parse_curve(curve)
    assert_kind_of Array, result
    assert_equal 13, result.length
    assert_equal 742, result[0][0]
    assert_equal 754, result[7][0]
  end
  
  
  def test_zip_channels
    tuples_x = [[1, 125], [3, 234], [5, 456], [9,876]]
    tuples_y = [[2, 437], [3, 123], [6, 432], [9, 430]]
    result = Tracksperanto::Import::NukeScript.new(:io => StringIO.new).send(:zip_curve_tuples, tuples_x, tuples_y)
    assert_equal [[3, 234, 123], [9, 876, 430]], result
  end
end
