# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class TestFlameImport < Test::Unit::TestCase
  DELTA = 0.1 
  
  def test_parsing_from_flame
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/hugeFlameSetup.stabilizer')
    
    parser = Tracksperanto::Import::FlameStabilizer.new(:io => fixture)
    trackers = parser.to_a
    
    assert_equal 2048, parser.width
    assert_equal 1176, parser.height
    
    parser.height = 1080
    
    assert_equal 28, trackers.length
    
    first_t = trackers[0]
    assert_equal 546, first_t.keyframes.length
    
    first_k = first_t.keyframes[1]
    
    assert_equal 1, first_k.frame
    assert_in_delta 771.58, first_k.abs_x, DELTA
    assert_in_delta 107.98192, first_k.abs_y, DELTA
  end
  
  def test_introspects_properly
    i = Tracksperanto::Import::FlameStabilizer
    assert_equal "Flame .stabilizer file", i.human_name
    assert i.autodetects_size?
  end
  
  def test_parsing_another_track
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/megaTrack.action.3dtrack.stabilizer')
    
    parser = Tracksperanto::Import::FlameStabilizer.new(:io => fixture)
    trackers = parser.to_a
    
    assert_equal 1920, parser.width
    assert_equal 1080, parser.height
    
    assert_equal 20, trackers.length
  end

  def test_simple_from_combustion
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer')
    
    parser = Tracksperanto::Import::FlameStabilizer.new(:io => fixture)
    trackers = parser.to_a
    
    assert_equal 1280, parser.width
    assert_equal 540, parser.height
    
    assert_equal 1, trackers.length
    
    t = trackers.shift
    assert_equal 232, t.keyframes.length
    
    first_kf = t.keyframes[0]
    
    assert_equal 0, first_kf.frame
    assert_in_delta 387.7752, first_kf.abs_x, DELTA
    assert_in_delta 514.4738, first_kf.abs_y, DELTA
    
    frame_149 = t.keyframes[148]
    assert_in_delta 390.267, frame_149.abs_x, DELTA
    assert_in_delta 280.248, frame_149.abs_y, DELTA
  end
  
  def test_from_tracksperanto
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/fromTracksperanto.stabilizer')
    trackers = Tracksperanto::Import::FlameStabilizer.new(:io => fixture).to_a
    
    assert_equal 3, trackers.length
    assert_equal 3, trackers[0].length
  end
  
  # flame 2012 changed the keyframe format
  def test_from_flame2012
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/Flame_Stabilizer_2012.stabilizer')
    trackers = Tracksperanto::Import::FlameStabilizer.new(:io => fixture).to_a
    
    assert_equal 5, trackers.length
    assert_equal 61, trackers[0].length
  end
  
  def test_from_flame2012_with_empty_trackers
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/flame_2012_another.stabilizer')
    trackers = Tracksperanto::Import::FlameStabilizer.new(:io => fixture).to_a
    assert_equal 1, trackers.length
    assert_equal 100, trackers[0].length
  end
  
  def test_from_flame2012_with_traced_messages
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/flame_2012_another.stabilizer')
    output = ""
    progress_block = lambda {|msg|  output << msg }
    trackers = Tracksperanto::Import::FlameStabilizer.new(:io => fixture, :progress_block => progress_block).to_a
    assert output.include?('Parsing channel "tracker1/shift/x"')
  end
  
  def test_bilinear_passes_proper_naming
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/cornerpin_2012.stabilizer')
    trackers = Tracksperanto::Import::FlameStabilizer.new(:io => fixture).to_a
    tracker_order = ["bottom_left", "bottom_right", "top_left", "top_right"]
    assert_equal tracker_order, trackers.map(&:name)
  end
  
  # flame 2014 has a new stabilizer
  def test_flame_2014_stabilizer_import
    fixture = File.open(File.dirname(__FILE__) + '/samples/flame_stabilizer/stabilizer_2014_stp.stabilizer')
    trackers = Tracksperanto::Import::FlameStabilizer.new(:io => fixture).to_a
    assert_equal 2, trackers.length
    assert_equal 56, trackers[0].length
    assert_equal 56, trackers[1].length
  end
  
end
