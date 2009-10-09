require File.dirname(__FILE__) + '/../helper'

class EqualizerExportTestTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_equalizer.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::Equalizer4, P
  end
  
  def test_exporter_meta
    assert_equal "3de_v4.txt", Tracksperanto::Export::Equalizer4.desc_and_extension
    assert_equal "3DE v4 point export .txt file", Tracksperanto::Export::Equalizer4.human_name
  end
end