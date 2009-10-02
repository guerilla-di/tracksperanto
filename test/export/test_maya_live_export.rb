require File.dirname(__FILE__) + "/../helper"

class MayaLiveExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_Mayalive.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::MayaLive, P
  end
end