# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class PrefixToolTest < Test::Unit::TestCase
  
  def test_action_description
    assert_equal "Prefix tracker names with text", Tracksperanto::Tool::Prefix.action_description
  end
  
  def test_prefix_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Tool::Prefix.new(receiver, :prefix => "foo")
    assert_equal "foo", m.prefix
  end
  
  def test_prefixes
    receiver = flexmock
    receiver.should_receive(:start_tracker_segment).once.with("Pre_Tracker")
    
    m = Tracksperanto::Tool::Prefix.new(receiver, :prefix => "Pre_")
    m.start_tracker_segment("Tracker")
  end

  def test_does_not_prefix_with_empty
    receiver = flexmock
    receiver.should_receive(:start_tracker_segment).once.with("Tracker")
    
    m = Tracksperanto::Tool::Prefix.new(receiver)
    m.start_tracker_segment("Tracker")
  end
  
end
