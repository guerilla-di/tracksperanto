require File.dirname(__FILE__) + '/../helper'

class MatchmoverExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_matchmover.rz2"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::MatchMover, P
  end
  
  def test_exporter_meta
    assert_equal "matchmover.rz2", Tracksperanto::Export::MatchMover.desc_and_extension
    assert_equal "Matchmover 2D export .rz2 file", Tracksperanto::Export::MatchMover.human_name
  end
  
end