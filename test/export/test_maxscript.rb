# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class MaxscriptExportTest < Test::Unit::TestCase
  include ParabolicTracks
  
  P_MAX = File.dirname(__FILE__) + "/samples/ref_Maxscript.ms"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::Maxscript, P_MAX
  end
  
  def test_exporter_meta
    assert_equal "3dsmax_nulls.ms", Tracksperanto::Export::Maxscript.desc_and_extension
    assert_equal "Autodesk 3dsmax script for nulls on an image plane", Tracksperanto::Export::Maxscript.human_name
  end
end
