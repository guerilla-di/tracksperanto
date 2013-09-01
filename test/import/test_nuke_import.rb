# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class NukeImportTest < Test::Unit::TestCase
  DELTA = 0.01 
  
  def test_introspects_properly
    i = Tracksperanto::Import::NukeScript
    assert_equal "Nuke .nk script file with Tracker, Reconcile3D, Transform2D, PlanarTracker and CornerPin nodes",
       i.human_name
    assert !i.autodetects_size?
    assert_not_nil i.known_snags
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
  
  def test_parsing_cornerpin
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/cornerpin.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 4096
    parser.height = 2304
    
    trackers = parser.to_a
    assert_equal 4, trackers.length
  end
  
  def test_parsing_planar_tracker
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/planar.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 4096
    parser.height = 2304
    
    trackers = parser.to_a
    assert_equal 4, trackers.length
    
    ref_names = %w( PlanarTracker2_outputBottomLeft PlanarTracker2_outputBottomRight 
      PlanarTracker2_outputTopLeft PlanarTracker2_outputTopRight )
    assert_equal ref_names, trackers.map{|e| e.name }
  end
  
  def test_parsing_planar_tracker_nuke7
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/nuke7_planar.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 1920
    parser.height = 1080
    
    trackers = parser.to_a
    assert_equal 4, trackers.length
    
    ref_names = %w( PlanarTracker1_outputBottomLeft PlanarTracker1_outputBottomRight 
      PlanarTracker1_outputTopLeft PlanarTracker1_outputTopRight )
    assert_equal ref_names, trackers.map{|e| e.name }
  end
  
  def test_parsing_xform2d_nuke7
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/nuke7_transform2d.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 1920
    parser.height = 1080
    
    trackers = parser.to_a
    ref_names = %w( Transform_for_AE_translate Transform_for_AE_center )
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
  
  def test_parsing_from_nuke7_tracker4
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/nuke7_tracker_2tracks.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 1280
    parser.height = 720
    
    trackers = parser.to_a
    assert_equal 2, trackers.length
    assert_equal "Tracker1_track_1", trackers[0].name
    assert_equal "Tracker1_track_2", trackers[1].name
    assert_equal 15, trackers[1].length
    
    kf = trackers[1][5]
    assert_in_delta 106.75, kf.abs_x, DELTA
    assert_in_delta 77.01, kf.abs_y, DELTA
    assert_equal 9, kf.frame
  end
  
  def test_parsing_nuke708_tracker4
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/nuke708_tracker.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 1152
    trackers = parser.to_a
    assert_equal 1, trackers.length
  end
  
  def test_parsing_nuke708_tracker4_with_curve_error
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/A099_L008_0207TW_001_head_R.nk')
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture, :width => 4800, :height => 2700)
    trackers = parser.to_a
    assert_equal 4, trackers.length
  end
  
  def test_parsing_from_nuke7v05_job_1872
    fixture = File.open(File.dirname(__FILE__) + '/samples/nuke/failing_nuke7_trackers_job_1872.nk')
    
    parser = Tracksperanto::Import::NukeScript.new(:io => fixture)
    parser.width = 2048
    parser.height = 1556
    
    trackers = parser.to_a
    assert_equal 2, trackers.length
    assert_equal "Tracker5_track_1", trackers[0].name
    assert_equal "Tracker5_track_2", trackers[1].name
    assert_equal 16, trackers[1].length
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
  
  def test_zip_channels
    tuples_x = [[1, 125], [3, 234], [5, 456], [9,876]]
    tuples_y = [[2, 437], [3, 123], [6, 432], [9, 430]]
    result = Tracksperanto::Import::NukeScript.new(:io => StringIO.new).send(:zip_curve_tuples, tuples_x, tuples_y)
    assert_equal [[3, 234, 123], [9, 876, 430]], result
  end
end
