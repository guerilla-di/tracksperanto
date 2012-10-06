# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class MoveToFirstFrameToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Move all the keyframes in time so that the first frame is the first animated keyframe", Tracksperanto::Tool::MoveToFirst.action_description
  end
  
  def test_move_to_first_frame
    receiver = flexmock
    receiver.should_receive(:start_export).with(120,120)

    receiver.should_receive(:start_tracker_segment).with("Tracker1")
    receiver.should_receive(:export_point).with(4, 100, 100, 0)
    receiver.should_receive(:end_tracker_segment)

    receiver.should_receive(:start_tracker_segment).with("Tracker2")
    receiver.should_receive(:export_point).with(0, 100, 100, 0)
    receiver.should_receive(:end_tracker_segment)

    receiver.should_receive(:end_export)
    
    m = Tracksperanto::Tool::MoveToFirst.new(receiver)
    
    m.start_export(120, 120)
    
    m.start_tracker_segment("Tracker1")
    m.export_point(14, 100, 100, 0)
    m.end_tracker_segment
    
    m.start_tracker_segment("Tracker1")
    m.export_point(10, 100, 100, 0)
    m.end_tracker_segment
    
    m.end_export
  end
end
