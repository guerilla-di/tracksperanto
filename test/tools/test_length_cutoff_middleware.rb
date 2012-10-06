# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class LengthCutoffToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Remove trackers that have less than the specified number of keyframes", Tracksperanto::Tool::LengthCutoff.action_description
  end
  
  def test_default_length_set_to_zero_and_ignored
    receiver = flexmock
    m = Tracksperanto::Tool::LengthCutoff.new(receiver)
    assert_equal 0, m.min_length
  end
  
  def test_slip_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Tool::LengthCutoff.new(receiver, :min_length => 23)
    assert_equal 23, m.min_length
  end
  
  def test_slipper_bypasses_methods
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(120,120)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    12.times do | i |
      receiver.should_receive(:export_point).with(i, 100, 100, 0)
    end
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    
    m = Tracksperanto::Tool::LengthCutoff.new(receiver, :min_length => 12)
    m.start_export(120, 120)
    m.start_tracker_segment("Tracker")
    12.times {|t|  m.export_point(t, 100, 100, 0) }
    m.end_tracker_segment
    m.start_tracker_segment("Tracker2")
    11.times {|t|  m.export_point(t, 100, 100, 0) }
    m.end_tracker_segment
    m.end_export
    
  end
end
