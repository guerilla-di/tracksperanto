require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class FlipToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Mirrors all the tracker paths horizontally", Tracksperanto::Tool::Flip.action_description
  end
  
  def test_export_with_enabled_flip
    receiver = flexmock(:exporter)
    receiver.should_receive(:start_export).once.with(110, 120)
    receiver.should_receive(:export_point).once.with(1, 100, 95, 0)

    m = Tracksperanto::Tool::Flip.new(receiver)
    m.start_export(110, 120)
    m.export_point(1, 10, 95, 0)
  end
end
