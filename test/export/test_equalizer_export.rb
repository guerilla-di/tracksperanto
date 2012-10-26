# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class Equalizer4ExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_equalizer.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::Equalizer4, P, "Please note this test might fail due to differences in float rounding between platforms"
  end
  
  def test_exporter_meta
    assert_equal "3de_v4.txt", Tracksperanto::Export::Equalizer4.desc_and_extension
    assert_equal "3DE v4 point export .txt file", Tracksperanto::Export::Equalizer4.human_name
  end
  
  def test_always_exports_first_frame_as_0
    buf = StringIO.new
    exporter = Tracksperanto::Export::Equalizer4.new(buf)
    exporter.start_export(1920, 1080)
    exporter.start_tracker_segment("First")
    exporter.export_point(14, 10.4, 10.9, 0)
    exporter.end_tracker_segment
    exporter.end_export
    
    assert_equal "1\nFirst\n0\n1\n1 10.400000000000000 10.900000000000000\n", buf.string, "The first keyframe should have been moved to 1"
  end
  
end
