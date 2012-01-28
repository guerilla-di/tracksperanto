# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class AEExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  P_LOCATORS = File.dirname(__FILE__) + "/samples/ref_AfterEffects.jsx"
  
  def test_export_output_written
    create_reference_output Tracksperanto::Export::AE, P_LOCATORS
    ensure_same_output Tracksperanto::Export::AE, P_LOCATORS
  end
  
end
