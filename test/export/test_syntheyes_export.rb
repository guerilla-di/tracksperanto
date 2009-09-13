require File.dirname(__FILE__) + '/../helper'

class SynthEyesExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_Syntheyes.txt"
  
  def test_export_output_written
    io = StringIO.new # File.open(P, "w")
    x = Tracksperanto::Export::SynthEyes.new(io)
    export_parabolics_with(x)
    io.close
    
    assert_equal io.string, File.read(P)
  end
  
  
  def test_exporter_meta
    assert_equal "syntheyes_2dt.txt", Tracksperanto::Export::SynthEyes.desc_and_extension
    assert_equal "Syntheyes 2D tracker .txt file", Tracksperanto::Export::SynthEyes.human_name
  end
end