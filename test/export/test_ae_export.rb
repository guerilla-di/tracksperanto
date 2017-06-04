require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class AEExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  P_LOCATORS = File.dirname(__FILE__) + "/samples/ref_AfterEffects.jsx"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::AE, P_LOCATORS
  end
  
  def test_exporter_meta
    assert_equal "createNulls.jsx", Tracksperanto::Export::AE.desc_and_extension
    assert_equal "AfterEffects .jsx script generating null layers", Tracksperanto::Export::AE.human_name
  end
end
