require File.dirname(__FILE__) + '/../helper'

class SynthEyesExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_Syntheyes.txt"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::SynthEyes, P
  end
  
  def test_exporter_meta
    assert_equal "syntheyes_2dt.txt", Tracksperanto::Export::SynthEyes.desc_and_extension
    assert_equal "Syntheyes 2D tracker paths file", Tracksperanto::Export::SynthEyes.human_name
  end
end