# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

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

  def test_flip_using_scaler
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(120, 80)
    receiver.should_receive(:export_point).once.with(1, 100, 20, 0)

    m = Tracksperanto::Middleware::Scaler.new(receiver, :x_factor => -1, :y_factor => -1)
    m.start_export(120, 80)
    m.export_point(1, 20, 60, 0)
  end

  def test_scaler_properly_affects_residual
    factor =  Math.sqrt( (1.5 ** 2) + (1.4 ** 2))
    
    receiver = flexmock
    receiver.should_receive(:start_export).once.with((50 * 1.5).to_i, (60 * 1.4).to_i)
    
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, 90, 42.0, 0.2 * factor)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Middleware::Scaler.new(receiver, :x_factor => 1.5, :y_factor => 1.4)
    m.start_export(50, 60)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 60, 30, 0.2)
    m.end_tracker_segment
    m.end_export
  end
end
