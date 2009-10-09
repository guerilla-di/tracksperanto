require File.dirname(__FILE__) + '/../helper'

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
end