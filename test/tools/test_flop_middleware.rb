# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class FlopToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Mirror all the tracker paths vertically", Tracksperanto::Tool::Flop.action_description
  end
  
  def test_export_flip_and_flop
    receiver = flexmock(:exporter)
    receiver.should_receive(:start_export).once.with(110, 120)
    receiver.should_receive(:export_point).once.with(1, 10, 25, 0)
    
    m = Tracksperanto::Tool::Flop.new(receiver)
    m.start_export(110, 120)
    m.export_point(1, 10, 95, 0)
  end
end
