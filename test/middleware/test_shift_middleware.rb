# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class ShiftMiddlewareTest < Test::Unit::TestCase
  def test_shift_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Middleware::Shift.new(receiver, :x_shift => 1.2)
    assert_equal 1.2, m.x_shift
  end
  
  def test_shift_bypasses_methods
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(50, 60)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, 123, 95, 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Middleware::Shift.new(receiver, :x_shift => 63, :y_shift => 65)
    m.start_export(50, 60)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 60, 30, 0)
    m.end_tracker_segment
    m.end_export
  end
  
end
