require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class SubpixelImportTest < Test::Unit::TestCase
  DELTA = 0.1
  
  # We know that the following apps use the edge of the pixel raster as 0:
  # Shake, Flame, 3DE.
  
  # In Syntheyes, the coordinates of the corners are effectively at the center of the pixels of the grid.
  # WE NEED to make adjustments to the Syntheyes workflows to account for "on-pixel" coordinates as opposed to "pixel corner"
  def test_parsing_from_syntheyes_2dp
    fixture = File.open(File.dirname(__FILE__) + '/sy_subpix_2dpaths.txt')
    trackers = Tracksperanto::Import::Syntheyes.new(:io => fixture, :width => 720, :height => 576).to_a
    
    bl_kf = trackers[2][0]
    assert_in_delta 0.0, bl_kf.abs_x, DELTA
    assert_in_delta 0.0, bl_kf.abs_y, DELTA

    tr_kf = trackers[3][0]
    assert_in_delta 720.0, tr_kf.abs_x, DELTA
    assert_in_delta 576.0, tr_kf.abs_y, DELTA
  end
  
  # In PFTrack the coordinates are shifted by .5 pixels and the 0 coordinate is not at the edge of the pixel raster,
  # but in the middle of the leftmost bottom pixel.
  def test_parsing_from_pftrack
    fixture = File.open(File.dirname(__FILE__) + '/julik_pftrack.txt')
    trackers = Tracksperanto::Import::PFTrack.new(:io => fixture, :width => 720, :height => 576).to_a
    
    bl_kf = trackers[0][0]
    assert_in_delta 0.5, bl_kf.abs_x, DELTA
    assert_in_delta 0.5, bl_kf.abs_y, DELTA
    
    tr_kf = trackers[1][0]
    assert_in_delta 715.5, tr_kf.abs_x, DELTA
    assert_in_delta 571.514, tr_kf.abs_y, DELTA
  end
  
  # Subpixel accuracy is native in Shake.
  # It is therefore IN LINE with the Tracksperanto spec.
  def test_parsing_from_shake_script
    fixture = File.open(File.dirname(__FILE__) + '/shake_subpix_v01.shk')
    
    trackers = Tracksperanto::Import::ShakeScript.new(:io => fixture, :width => 720, :height => 576).to_a
    assert_equal 2, trackers.length
    
    bl_kf = trackers[0][0]
    assert_in_delta 0.5, bl_kf.abs_x, DELTA
    assert_in_delta 0.5, bl_kf.abs_y, DELTA
    
    tr_kf = trackers[1][0]
    assert_in_delta 715.5, tr_kf.abs_x, DELTA
    assert_in_delta 571.514, tr_kf.abs_y, DELTA
  end
  
  # Flame DOES allow subpix references, however in Action the coordinates of the first tracked keyframe
  # will be nudged to whole pixels. Which is shit. However we care about the stabilizer data, not about
  # how it gets applied.
  # Subpixel handling in Flame is therefore IN LINE with the Tracksperanto spec.
  def test_from_flame_setup
    fixture = File.open(File.dirname(__FILE__) + '/Flame_Smk2013_SubpixSample.stabilizer')
    t = Tracksperanto::Import::FlameStabilizer.new(:io => fixture).to_a[0]
    first_kf = t[0]
    assert_in_delta 0.5, first_kf.abs_x, DELTA
    assert_in_delta 0.5, first_kf.abs_y, DELTA
  end
  
  # Nuke properly computes coordinates off the corner.
  # def test_from_nuke_script
  #   fixture = File.open(File.dirname(__FILE__) + '/julik_nuke.nk')
  #   t = Tracksperanto::Import::NukeScript.new(:width => 720, :height => 576, :io => fixture).to_a
  #   assert_equal 1, t.length, "Should have imported one tracker"
  # end
end
