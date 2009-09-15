require File.dirname(__FILE__) + '/../helper'

class NukeExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_NukeScript.nk"
  
  def test_export_output_written
    io = StringIO.new
    x = Tracksperanto::Export::NukeScript.new(io)
    export_parabolics_with(x)
    io.close
    
    assert_equal io.string, File.read(P)
  end
  
  def test_exporter_meta
    assert_equal "nuke.nk", Tracksperanto::Export::NukeScript.desc_and_extension
    assert_equal "Nuke .nk script", Tracksperanto::Export::NukeScript.human_name
  end
  
  def test_tuples_to_curves
    tuples = [[6, 234, 145], [8, 144, 223], [9, 231, 189]]
    x = Tracksperanto::Export::NukeScript.new(StringIO.new)
    curves = x.curves_from_tuples(tuples)
    assert_equal "{curve i x6 234.0000 x8 144.0000 231.0000} {curve i x6 145.0000 x8 223.0000 189.0000}", curves
  end
end