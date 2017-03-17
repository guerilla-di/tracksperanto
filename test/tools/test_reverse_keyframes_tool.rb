# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class ReverseKeyframesTest < Test::Unit::TestCase
  MUT = Tracksperanto::Tool::ReverseKeyframes
  def test_action_description
    assert_equal "Reverse the tracker keyframes in time. Assumes the timing starts at frame 1.", MUT.action_description
  end

  def test_supports_hash_init
    receiver = flexmock
    m = MUT.new(receiver, {})
  end

  def test_reverse_frame
    m = MUT.new(nil)
    assert_equal 9, m.reverse_frame(1, 2, 10)
    assert_equal 7, m.reverse_frame(1, 5, 11)
  end

  def test_bypasses_methods
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(120,120)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(0, 100, 100, 0)
    receiver.should_receive(:export_point).once.with(50, 1, 1, 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = MUT.new(receiver)
    m.start_export(120, 120)
    m.start_tracker_segment("Tracker")
    m.export_point(0, 1, 1, 0)
    m.export_point(50, 100, 100, 0)
    m.end_tracker_segment
    m.end_export
  end
end
