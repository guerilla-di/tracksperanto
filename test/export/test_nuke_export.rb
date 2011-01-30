require File.dirname(__FILE__) + '/../helper'

class NukeExportTest < Test::Unit::TestCase
  include ParabolicTracks
  TEST_FILE = File.dirname(__FILE__) + "/samples/ref_NukeScript.nk"
  PREAMBLE = 'version 5.1200
Root {
 inputs 0
 frame 1
 last_frame 1
}
Constant {
 inputs 0
 channels rgb
 format "1080 720 0 0 1080 720 1"
 name CompSize_1080x720
 postage_stamp false
 xpos 0
 ypos -60
}'
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::NukeScript, TEST_FILE
  end
  
  def test_exporter_meta
    assert_equal "nuke.nk", Tracksperanto::Export::NukeScript.desc_and_extension
    assert_equal "Nuke .nk script", Tracksperanto::Export::NukeScript.human_name
  end
  
  def test_tuples_to_curves
    tuples = [[6, 234, 145], [8, 144, 223], [9, 231, 189], [10, 232, 190]]
    x = Tracksperanto::Export::NukeScript.new(StringIO.new)
    curves = x.send(:curves_from_tuples, tuples)
    assert_equal "{curve i x6 234.0000 x8 144.0000 x9 231.0000 232.0000} {curve i x6 145.0000 x8 223.0000 x9 189.0000 190.0000}", curves
  end
  
  def test_compsize_not_overridden
    o = StringIO.new
    x = Tracksperanto::Export::NukeScript.new(o)
    x.start_export(1080, 720)
    x.end_export
    assert_equal PREAMBLE, o.string.strip 
  end
  
end