# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class CropMiddlewareTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Crop or pad the image by a specified number of pixels", Tracksperanto::Middleware::Crop.action_description
  end
  
  def test_crop_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Middleware::Crop.new(receiver, :left => 13, :right => 0, :top => 25)
  end
  
  def test_shift_bypasses_methods
    receiver = flexmock
    padded_w, padded_h = 720 - 60, 576 + 58
    
    receiver.should_receive(:start_export).once.with(padded_w, padded_h)
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    receiver.should_receive(:export_point).once.with(1, 120.0, -28.0, 0)
    receiver.should_receive(:end_tracker_segment).once
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Middleware::Crop.new(receiver, :left => -60, :bottom => 58)
    m.start_export(720, 576)
    m.start_tracker_segment("Tracker")
    m.export_point(1, 60, 30, 0)
    m.end_tracker_segment
    m.end_export
  end
  
end
