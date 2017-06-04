require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class PadToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Pad or crop the image by a fraction of it's original size", Tracksperanto::Tool::Pad.action_description
  end
  
  def test_shift_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Tool::Pad.new(receiver, 
      :left_pad => 0.5, :right_pad => 0, :top_pad => -0.2)
    assert_in_delta 0.5, m.left_pad, 0.001 
    assert_in_delta 0.0, m.bottom_pad, 0.001 
  end
  
  def test_shift_bypasses_methods
    receiver = flexmock
    padded_w, padded_h = (720 * 0.75).ceil, (576 * 1.1).ceil
    
    receiver.should_receive(:start_export).once.with(padded_w, padded_h)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, 240.0, -27.6, 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Tool::Pad.new(receiver, :left_pad => -0.25, :bottom_pad => 0.10)
    m.start_export(720, 576)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 60, 30, 0)
    m.end_tracker_segment
    m.end_export
  end
  
end
