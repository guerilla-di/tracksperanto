# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class LerpToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Interpolate missing keyframes of all the trackers", Tracksperanto::Tool::Lerp.action_description
  end
  
  def test_lerp
    receiver = flexmock
    m = Tracksperanto::Tool::Lerp.new(receiver)
    receiver.should_receive(:start_export).with(720, 576).once
    receiver.should_receive(:start_tracker_segment).with("Foo").once
    receiver.should_receive(:export_point).with(1, 1.0, 2.0, 0).once
    receiver.should_receive(:export_point).with(2, 2.0, 3.0, 0).once
    receiver.should_receive(:export_point).with(3, 3.0, 4.0, 0).once
    receiver.should_receive(:export_point).with(4, 4.0, 5.0, 0).once
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m.start_export(720, 576)
    m.start_tracker_segment("Foo")
    m.export_point(1, 1.0, 2.0, 0)
    m.export_point(4, 4.0, 5.0, 0)
    m.end_tracker_segment
    m.end_export
  end
end
