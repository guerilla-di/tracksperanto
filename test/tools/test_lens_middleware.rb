# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class LensToolTest < Test::Unit::TestCase
  
  include Approximately
  
  def test_action_description
    assert_equal "Apply or remove lens distortion with the Syntheyes algorithm", Tracksperanto::Tool::LensDisto.action_description
  end
  
  def test_lens_bypasses_centerpoint
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(1920, 1080)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, 1920 / 2.0, 1080.0 / 2.0, 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Tool::LensDisto.new(receiver, :k => 0.0168)
    m.start_export(1920, 1080)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 1920 / 2.0, 1080.0 / 2.0, 0)
    m.end_tracker_segment
    m.end_export
  end
  
  def test_lens_distorted
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(1920, 1080)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, approx(66.03), approx(43.978), approx(0))
    
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Tool::LensDisto.new(receiver, :k => -0.0298, :kcube => 0.0078)
    m.start_export(1920, 1080)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 12.0, 14.0, 0)
    m.end_tracker_segment
    m.end_export
  end
  
  def test_lens_undistorted
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(1920, 1080)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, approx(11.999914830236555), approx(13.99995274335909), 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Tool::LensDisto.new(receiver, :k => -0.0298, :kcube => 0.0078, :remove => true)
    m.start_export(1920, 1080)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 66.03001446825158, 43.978678913818925, 0)
    m.end_tracker_segment
    m.end_export
  end
  
  def test_roundtrip
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(1920, 1080)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, approx(0.984), approx(0.991), 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    apply = Tracksperanto::Tool::LensDisto.new(receiver, :k => -0.0298, :kcube => 0.2178)
    remove = Tracksperanto::Tool::LensDisto.new(apply, :k => -0.0298, :kcube => 0.2178, :remove => true)
    
    remove.start_export(1920, 1080)
    remove.start_tracker_segment("Tracker")
    remove.export_point(1, 1.0, 1.0, 0)
    remove.end_tracker_segment
    remove.end_export
  end
end
