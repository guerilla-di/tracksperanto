# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'
#ENV['TRACKSPERANTO_OVERWRITE_ALL_TEST_DATA'] = 'yes'
class TestFlameStabilizer2014Export < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_flame_2014.stabilizer"
  
  def test_export_output_written
    t = Time.local(2014, "Feb", 22, 11, 3, 0)
    flexmock(Time).should_receive(:now).and_return(t)
    ensure_same_output Tracksperanto::Export::FlameStabilizer2014, P 
  end
  
  def test_exporter_meta
    assert_equal "flamesmoke2014.stabilizer", Tracksperanto::Export::FlameStabilizer2014.desc_and_extension
    assert_equal "Flame/Smoke 2D Stabilizer setup (v. 2014 and above)", Tracksperanto::Export::FlameStabilizer2014.human_name
  end
end
