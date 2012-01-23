# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class ShakeTextExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_ShakeText.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::ShakeText, P
  end
  
  def test_exporter_meta
    assert_equal "shake_trackers.txt", Tracksperanto::Export::ShakeText.desc_and_extension
    assert_equal "Shake trackers in a .txt file (also usable with Nuke's CameraTracker)", Tracksperanto::Export::ShakeText.human_name
  end
end
