require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class PFMatchitExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  def test_human_name
    assert_equal "PFMatchit .2dt file (single camera)", Tracksperanto::Export::PFMatchit.human_name
  end
  
  def test_desc_and_ext
    assert_equal "pfmatchit.2dt", Tracksperanto::Export::PFMatchit.desc_and_extension
  end
  
  P = File.dirname(__FILE__) + "/samples/ref_PFMatchit.2dt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::PFMatchit, P
  end
end