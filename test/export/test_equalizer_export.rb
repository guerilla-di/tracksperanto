require File.dirname(__FILE__) + '/../helper'

class EqualizerExportTestTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_equalizer.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::Equalizer, P
  end
  
  def test_exporter_meta
    assert_equal "3de.txt", Tracksperanto::Export::Equalizer.desc_and_extension
    assert_equal "3DE point export .txt file", Tracksperanto::Export::Equalizer.human_name
  end
end