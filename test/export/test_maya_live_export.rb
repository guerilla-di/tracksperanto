require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class MayaLiveExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P_STD_ASPECT = File.dirname(__FILE__) + "/samples/ref_Mayalive.txt"
  P_CUSTOM_ASPECT = File.dirname(__FILE__) + "/samples/ref_Mayalive_CustomAspect.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::MayaLive, P_STD_ASPECT
  end
  
  def test_export_output_written_for_custom_aspect
    ensure_same_output(Tracksperanto::Export::MayaLive, P_CUSTOM_ASPECT) do | exporter |
      exporter.aspect = 1.78
    end
  end
end
