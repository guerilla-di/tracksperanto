require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class TestFlameStabilizer2014CornerpinExport < Test::Unit::TestCase
  IN = File.dirname(__FILE__) + "/../import/samples/flame_stabilizer/stabilizer_2014_ref_for_reexport.stabilizer"
  OUT = File.dirname(__FILE__) + "/samples/ref_flame_2014_cornerpin.stabilizer"
  
  include ParabolicTracks
  
  def test_roundtrip_export
    importer = Tracksperanto::Import::FlameStabilizer.new(:io => File.open(IN))
    trackers = importer.to_a.shuffle # Ensure we are not in correct order
    assert_equal 4, trackers.length
    trackers.each_with_index {|t, i | t.name = "randomName#{i}"}
    
    io = StringIO.new
    
    t = Time.local(2014, "Feb", 22, 11, 3, 0)
    flexmock(Time).should_receive(:now).and_return(t)
    
    x = Tracksperanto::Export::FlameStabilizer2014Cornerpin.new(io)
    x.just_export(trackers, importer.width, importer.height)
    io.rewind
    
    assert_same_buffer(File.open(OUT, "r"), io, "Shoudl have exported the same buffer")
  end
  
  def test_exporter_meta
    assert_equal "flamesmoke_2014_cornerpin.stabilizer", 
      Tracksperanto::Export::FlameStabilizer2014Cornerpin.desc_and_extension
    assert_equal "Flame/Smoke 2D Stabilizer setup (v. 2014 and above) for corner pins", 
      Tracksperanto::Export::FlameStabilizer2014Cornerpin.human_name
  end
end
