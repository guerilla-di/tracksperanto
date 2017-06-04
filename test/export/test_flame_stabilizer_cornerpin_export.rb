require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class FlameStabilizerCornerpinExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_flameCornerpin.stabilizer"
  P2 = File.dirname(__FILE__) + "/samples/ref_FlameSimpleReorderedCornerpin.stabilizer"
  P3 = File.dirname(__FILE__) + "/samples/ref_FlameProperlyReorderedCornerpin.stabilizer"
  
  def test_export_output_written
    t = Time.local(2010, "Feb", 18, 17, 22, 12)
    flexmock(Time).should_receive(:now).and_return(t)
    ensure_same_output Tracksperanto::Export::FlameStabilizerCornerpin, P 
  end
  
  def test_exporter_meta
    assert_equal "flame_cornerpin.stabilizer", Tracksperanto::Export::FlameStabilizerCornerpin.desc_and_extension
    assert_equal "Flame/Smoke 2D Stabilizer setup for bilinear corner pins", Tracksperanto::Export::FlameStabilizerCornerpin.human_name
  end
  
  def test_only_ever_exports_4_points
    s = StringIO.new
    x = Tracksperanto::Export::FlameStabilizerCornerpin.new(s)
    
    trackers = (1..40).map do | i |
      Tracksperanto::Tracker.new(:name => "Foe#{i}") do | t |
        7.times {|j|  t.keyframe! :frame => j, :abs_x => 123, :abs_y => 456 }
      end
    end
    x.just_export(trackers, 720, 576)
    s.rewind
    
    roundtrip = Tracksperanto::Import::FlameStabilizer.new(:io => s).to_a
    assert_equal 4, roundtrip.length
  end
  
  def test_roundtrip_with_correct_order
    t = Time.local(2010, "Feb", 18, 17, 22, 12)
    flexmock(Time).should_receive(:now).and_return(t)
    
    trackers = File.open(File.dirname(__FILE__) + "/../import/samples/flame_stabilizer/FlameStab_Cornerpin_CorrectOrder.stabilizer") do | f| 
      Tracksperanto::Import::FlameStabilizer.new(:io => f).to_a
    end
    assert_equal 4, trackers.length
    
    s = StringIO.new
    x = Tracksperanto::Export::FlameStabilizerCornerpin.new(s)
    x.just_export(trackers, 1920, 1080)
    
    s.rewind
    
    assert_same_buffer(File.open(P2), s)
  end
  
  def test_roundtrip_with_incorrect_order
    t = Time.local(2010, "Feb", 18, 17, 22, 12)
    flexmock(Time).should_receive(:now).and_return(t)
    
    trackers = File.open(File.dirname(__FILE__) + "/../import/samples/flame_stabilizer/FlameStab_Cornerpin_IncorrectOrder.stabilizer") do | f| 
      Tracksperanto::Import::FlameStabilizer.new(:io => f).to_a
    end
    assert_equal 4, trackers.length
    
    s = StringIO.new
    x = Tracksperanto::Export::FlameStabilizerCornerpin.new(s)
    x.just_export(trackers, 1920, 1080)
    
    s.rewind
    
    assert_same_buffer(File.open(P3), s)
  end
end
