require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class Equalizer3ExportTestTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_equalizer3.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::Equalizer3, P
  end
  
  def test_exporter_meta
    assert_equal "3de_v3.txt", Tracksperanto::Export::Equalizer3.desc_and_extension
    assert_equal "3DE v3 point export .txt file", Tracksperanto::Export::Equalizer3.human_name
  end
  
  def test_export_for_format_does_not_override_preamble
    out = StringIO.new
    expt = Tracksperanto::Export::Equalizer3.new(out)
    expt.start_export(2048, 275)
    expt.end_export
    assert_equal "// 3DE Multiple Tracking Curves Export 2048 x 275 * 0 frames\n\n", out.string,
      "Frame count should not bleed into width"
  end
end
