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
  
  def test_width_and_height_not_stepping_on_each_other_in_preamble
    o = StringIO.new
    expt = Tracksperanto::Export::MatchMover.new(o)
    expt.start_export(1080, 720)
    expt.end_export
    assert_equal "imageSequence\t\"Sequence 01\"\n{\n\t1080\t720\tf( \"D:/temp/sequence.%04d.dpx\" )\tb( 1 211 1 )\t\n}\n",
      o.string,
      "The output width and height should be properly substituted"
  end
end