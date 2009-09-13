require File.dirname(__FILE__) + '/../helper'

class ShakeTextExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_ShakeText.txt"
  
  def test_export_output_written
    io = StringIO.new
    x = Tracksperanto::Export::ShakeText.new(io)
    export_parabolics_with(x)
    io.close
    
    assert_equal io.string, File.read(P)
  end
end