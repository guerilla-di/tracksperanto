# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class FlameStabilizerExportTestTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_flame.stabilizer"
  
  def test_export_output_written
    t = Time.local(2010, "Feb", 18, 17, 22, 12)
    flexmock(Time).should_receive(:now).once.and_return(t)
    ensure_same_output Tracksperanto::Export::FlameStabilizer, P 
  end
  
  def test_exporter_meta
    assert_equal "flame.stabilizer", Tracksperanto::Export::FlameStabilizer.desc_and_extension
    assert_equal "Flame/Smoke 2D Stabilizer setup", Tracksperanto::Export::FlameStabilizer.human_name
  end
end
