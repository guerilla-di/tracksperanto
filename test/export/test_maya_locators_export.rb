# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class MayaLocatorsExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  P_LOCATORS = File.dirname(__FILE__) + "/samples/ref_MayaLocators.ma"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::MayaLocators, P_LOCATORS
  end
  
  def test_exporter_meta
    assert_equal "mayaLocators.ma", Tracksperanto::Export::MayaLocators.desc_and_extension
    assert_equal "Maya ASCII scene with locators on an image plane", Tracksperanto::Export::MayaLocators.human_name
  end
end
