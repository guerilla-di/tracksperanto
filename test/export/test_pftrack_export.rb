require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class PFTrackExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  def test_human_name
    assert_equal "PFTrack v4 .2dt file", Tracksperanto::Export::PFTrack4.human_name
  end
  
  def test_desc_and_ext
    assert_equal "pftrack_v4.2dt", Tracksperanto::Export::PFTrack4.desc_and_extension
  end
  
  P = File.dirname(__FILE__) + "/samples/ref_PFTrack.2dt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::PFTrack4, P
  end
end