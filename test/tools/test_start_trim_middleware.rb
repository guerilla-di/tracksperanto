# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class StartTrimToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Remove all the keyframes that are on frames below 1", Tracksperanto::Tool::StartTrim.action_description
  end
  
  def test_start_mw_works
    x = flexmock(:exporter)
    
    x.should_receive(:start_export).once.with(720, 576)
    x.should_receive(:start_tracker_segment).once.with("TrackerBehind")
    x.should_receive(:export_point).once.with(0, 100, 100, 0.56)
    x.should_receive(:end_tracker_segment).once
    x.should_receive(:end_export).once
    
    m = Tracksperanto::Tool::StartTrim.new(x)
    
    m.start_export(720, 576)
    m.start_tracker_segment("TrackerBehind")
    m.export_point(-2, 120, 87, 0.56)
    m.export_point(-1, 110, 92, 0.56)
    m.export_point(0, 100, 100, 0.56)
    m.end_tracker_segment
    
    # This tracker should be skipped since it's now entirely behind the 0 frame mark
    m.start_tracker_segment("SecondTracker")
    m.export_point(-567, 120, 87, 0.56)
    m.export_point(-566, 110, 92, 0.56)
    m.export_point(-564, 100, 100, 0.56)
    m.end_tracker_segment
    
    m.end_export
  end
end
