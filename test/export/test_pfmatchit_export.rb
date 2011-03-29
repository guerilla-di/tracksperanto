require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class PFMatchitExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  def test_desc_and_ext
    assert_equal "PFMatchit user track export file (single camera)", Tracksperanto::Export::PFMatchit.human_name
    assert_equal "pfmatchit.txt", Tracksperanto::Export::PFMatchit.desc_and_extension
  end
  
  P = File.dirname(__FILE__) + "/samples/ref_PFMatchit.2dt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::PFMatchit, P
  end
end