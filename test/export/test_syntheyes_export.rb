require File.dirname(__FILE__) + '/../helper'

class SyntheyesExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_Syntheyes.txt"
  
  def test_export_output_written
    io = StringIO.new # File.open(P, "w")
    x = Tracksperanto::Export::SynthEyes.new(io)
    export_parabolics_with(x)
    io.close
    
    assert_equal io.string, File.read(P)
  end
end