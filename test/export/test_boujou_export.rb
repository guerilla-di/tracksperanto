# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class BoujouExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_boujou.txt"
  
  def test_export_output_written
    t = Time.local(2010, "Apr", 15, 17, 21, 26)
    flexmock(Time).should_receive(:now).once.and_return(t)
    ensure_same_output Tracksperanto::Export::Boujou, P
  end
  
  def test_exporter_meta
    assert_equal "boujou_text.txt", Tracksperanto::Export::Boujou.desc_and_extension
    assert_equal "boujou feature tracks", Tracksperanto::Export::Boujou.human_name
  end
end
