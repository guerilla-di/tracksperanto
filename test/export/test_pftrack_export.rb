require File.dirname(__FILE__) + '/../helper'

class PFTrackExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  def test_human_name
    assert_equal "PFTrack .2dt file", Tracksperanto::Export::PFTrack.human_name
  end
  
  def test_desc_and_ext
    assert_equal "pftrack.2dt", Tracksperanto::Export::PFTrack.desc_and_extension
  end
  P = File.dirname(__FILE__) + "/samples/ref_PFTrack.2dt"
  def test_export_output_written
    io = StringIO.new #File.open(P, "w+")
    export_parabolics_with(Tracksperanto::Export::PFTrack.new(io))
    io.close
    
    assert_equal io.string, File.read(P)
  end
end