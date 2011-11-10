require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class FlameStabilizerCornerpinExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_flameCornerpin.stabilizer"
  
  def test_export_output_written
    t = Time.local(2010, "Feb", 18, 17, 22, 12)
    flexmock(Time).should_receive(:now).once.and_return(t)
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
end