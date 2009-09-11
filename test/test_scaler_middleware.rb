require File.dirname(__FILE__) + '/helper'

class ScalerMiddlewareTest < Test::Unit::TestCase
  def test_default_factor_set_to_one
    receiver = flexmock
    m = Tracksperanto::Middleware::Scaler.new(receiver)
    assert_equal 1.0, m.x_factor
    assert_equal 1.0, m.y_factor
  end
  
  def test_scaler_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Middleware::Scaler.new(receiver, :x_factor => 1.2)
    assert_equal 1.2, m.x_factor
  end
  
  def test_scaler_bypasses_methods
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(100,180)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, 120, 90, 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Middleware::Scaler.new(receiver, :x_factor => 2, :y_factor => 3)
    m.start_export(50, 60)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 60, 30, 0)
    m.end_tracker_segment
    m.end_export
  end
end