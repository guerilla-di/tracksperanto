require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class SyntheyesImportTest < Test::Unit::TestCase
  DELTA = 0.01 # our SynthEyes sample is somewhat inaccurate :-P
  
  def test_introspects_properly
    i = Tracksperanto::Import::Syntheyes
    assert_equal 'Syntheyes "Tracker 2-D paths" file', i.human_name
    assert !i.autodetects_size?
    assert_not_nil i.known_snags
    assert !i.known_snags.empty?
  end
  
  def test_parsing_from_importable
    fixture = File.open(File.dirname(__FILE__) + '/samples/syntheyes_2d_paths/shake_tracker_nodes_to_syntheyes.txt')
    trackers = Tracksperanto::Import::Syntheyes.new(:io => fixture, :width => 2560, :height => 1080).to_a
    
    assert_equal 50, trackers.length
    
    first_kf = trackers[0].keyframes[0]
    
    assert_equal "Tracker1", trackers[0].name
    
    assert_equal 0, first_kf.frame
    assert_in_delta 715.221, first_kf.abs_x, DELTA
    assert_in_delta 885.679, first_kf.abs_y, DELTA
    assert_in_delta 0.0, first_kf.residual, DELTA
  end
  
  def test_parsing_cola_plate
    fixture = File.open(File.dirname(__FILE__) + '/samples/syntheyes_2d_paths/cola_plate.txt')
    trackers = Tracksperanto::Import::Syntheyes.new(:io => fixture, :width => 1920, :height => 1080).to_a
    
    assert_equal 6, trackers.length
  end
  
  def test_parsing_with_one_tracker
    fixture = File.open(File.dirname(__FILE__) + '/samples/syntheyes_2d_paths/one_tracker.txt')
    trackers = Tracksperanto::Import::Syntheyes.new(:io => fixture, :width => 1920, :height => 1080).to_a
    
    assert_equal 1, trackers.length
    assert_equal 49, trackers[0].length
  end
  
  def test_parsing_from_sy_2010
    fixture = File.open(File.dirname(__FILE__) + '/samples/syntheyes_2d_paths/morePoints_sy2010.txt')
    trackers = Tracksperanto::Import::Syntheyes.new(:io => fixture, :width => 1920, :height => 1080).to_a
    
    assert_equal 26, trackers.length
  end
end
