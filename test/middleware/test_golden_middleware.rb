require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class GoldenMiddlewareTest < Test::Unit::TestCase
  def test_default_golden_set_to_false
    receiver = flexmock
    m = Tracksperanto::Middleware::Golden.new(receiver)
    assert_equal false, m.enabled
  end
  
  def test_golden_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Middleware::Golden.new(receiver, :enabled => true)
    assert_equal true, m.enabled
  end
  
  def test_golden_bypasses_methods
    receiver = flexmock
    
    receiver.should_receive(:start_export).once.with(120,120)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(0, 100, 100, 0.0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Middleware::Golden.new(receiver, :enabled => true)
    m.start_export(120, 120)
    m.start_tracker_segment("Tracker")
    m.export_point(0, 100, 100, 0.56)
    m.end_tracker_segment
    m.end_export
  end
end