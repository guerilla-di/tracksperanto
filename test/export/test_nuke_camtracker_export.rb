# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class NukeCamTrackerExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_NukeCameraTrackerUsertracks.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::NukeCameraUsertracks, P
  end
  
  def test_exporter_meta
    assert_equal "nuke_cam_trk_autotracks.txt", Tracksperanto::Export::NukeCameraUsertracks.desc_and_extension
    assert_equal "Nuke CameraTracker node autotracks (enable import/export in the Tracking tab)", Tracksperanto::Export::NukeCameraUsertracks.human_name
  end
end
