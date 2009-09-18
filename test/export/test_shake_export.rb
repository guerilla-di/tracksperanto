require File.dirname(__FILE__) + '/../helper'

class ShakeTextExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_ShakeText.txt"
  
  def test_export_output_written
    io = StringIO.new
    x = Tracksperanto::Export::ShakeText.new(io)
    export_parabolics_with(x)
    io.close
    
    assert_equal File.read(P), io.string
  end
  
  def test_exporter_meta
    assert_equal "shake_trackers.txt", Tracksperanto::Export::ShakeText.desc_and_extension
    assert_equal "Shake trackers in a .txt file", Tracksperanto::Export::ShakeText.human_name
  end
end