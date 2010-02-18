require File.dirname(__FILE__) + '/../helper'

class Equalizer4ExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_equalizer.txt"
  
  def test_export_output_written
    # This test might be failing due to different float rounding between platforms
    # (currently fails on win ruby and jruby)
    ensure_same_output Tracksperanto::Export::Equalizer4, P, "Please note this test might fail due to differences in float rounding between platforms"
  end
  
  def test_exporter_meta
    assert_equal "3de_v4.txt", Tracksperanto::Export::Equalizer4.desc_and_extension
    assert_equal "3DE v4 point export .txt file", Tracksperanto::Export::Equalizer4.human_name
  end
end