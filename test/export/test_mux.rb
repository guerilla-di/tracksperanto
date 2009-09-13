require File.dirname(__FILE__) + '/../helper'

class MuxTest < Test::Unit::TestCase
  
  def test_mux_replays
    outs = (0..25).map do
      o = flexmock
      o.should_receive(:start_export).once.with(720, 576)
      o.should_receive(:start_tracker_segment).once.with("FooT")
      o.should_receive(:export_point).once.with(0, 45.0, 67.0, 0.3)
      o.should_receive(:end_tracker_segment).once
      o.should_receive(:end_export).once
      o
    end
    
    mux = Tracksperanto::Export::Mux.new(outs)
    mux.start_export(720, 576)
    mux.start_tracker_segment("FooT")
    mux.export_point(0, 45.0, 67.0, 0.3)
    mux.end_tracker_segment
    mux.end_export
  end
end