require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class PFTrack5ExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  def test_human_name
    assert_equal "PFTrack 2011 .txt file (single camera)", Tracksperanto::Export::PFTrack2011.human_name
  end
  
  def test_desc_and_ext
    assert_equal "pftrack_2011.txt", Tracksperanto::Export::PFTrack2011.desc_and_extension
  end
  
  P = File.dirname(__FILE__) + "/samples/ref_PFTrack2011.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::PFTrack2011, P
  end
end