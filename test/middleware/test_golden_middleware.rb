# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class GoldenMiddlewareTest < Test::Unit::TestCase
  
  def test_golden_bypasses_methods
    receiver = flexmock
    
    receiver.should_receive(:start_export).once.with(120,120)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(0, 100, 100, 0.0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Middleware::Golden.new(receiver)
    m.start_export(120, 120)
    m.start_tracker_segment("Tracker")
    m.export_point(0, 100, 100, 0.56)
    m.end_tracker_segment
    m.end_export
  end
end
