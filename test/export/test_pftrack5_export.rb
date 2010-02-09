require File.dirname(__FILE__) + '/../helper'

class PFTrack5ExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  def test_human_name
    assert_equal "PFTrack v5 .2dt file", Tracksperanto::Export::PFTrack5.human_name
  end
  
  def test_desc_and_ext
    assert_equal "pftrack_v5.2dt", Tracksperanto::Export::PFTrack5.desc_and_extension
  end
  
  P = File.dirname(__FILE__) + "/samples/ref_PFTrack5.2dt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::PFTrack5, P
  end
end