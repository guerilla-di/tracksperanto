require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class SlipToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Slip all the tracker keyframes in time", Tracksperanto::Tool::Slipper.action_description
  end
  
  def test_default_slip_set_to_zero
    receiver = flexmock
    m = Tracksperanto::Tool::Slipper.new(receiver)
    assert_equal 0, m.slip
  end
  
  def test_slip_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Tool::Slipper.new(receiver, :slip => -1)
    assert_equal -1, m.slip
  end
  
  def test_slipper_bypasses_methods
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(120,120)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(32, 100, 100, 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Tool::Slipper.new(receiver, :slip => 32)
    m.start_export(120, 120)
    m.start_tracker_segment("Tracker")
    m.export_point(0, 100, 100, 0)
    m.end_tracker_segment
    m.end_export
  end
end
