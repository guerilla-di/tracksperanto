require File.dirname(__FILE__) + '/helper'

class SimpleExportTest < Test::Unit::TestCase
  
  class Probe
    include Tracksperanto::SimpleExport
  end
  
  def test_message_sends
    probe = Probe.new
    flexmock(probe).should_receive(:start_export).with(1920, 1080).once
    flexmock(probe).should_receive(:start_tracker_segment).with("Foo").once
    flexmock(probe).should_receive(:export_point).with(2, 345.0, 678.0, 0.0).once
    flexmock(probe).should_receive(:end_tracker_segment).once
    flexmock(probe).should_receive(:end_export).once
  
    t = Tracksperanto::Tracker.new(:name => "Foo")
    t.keyframe! :frame => 2, :abs_x => 345.0, :abs_y => 678.0, :residual => 0.0
    probe.just_export([t], 1920, 1080)
  end

end