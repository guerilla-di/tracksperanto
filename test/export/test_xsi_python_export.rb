require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class XSIExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  P_XSI = File.dirname(__FILE__) + "/samples/ref_XSI.py"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::XSI, P_XSI
  end
  
  def test_exporter_meta
    assert_equal "xsi_nulls.py", Tracksperanto::Export::XSI.desc_and_extension
    assert_equal "Autodesk Softimage nulls Python script", Tracksperanto::Export::XSI.human_name
  end
end
