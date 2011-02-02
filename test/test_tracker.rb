require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TrackerTest < Test::Unit::TestCase
  
  def test_supports_block_init
    t = Tracksperanto::Tracker.new do |t| 
      t.name = 'Foo'
    end
    assert_equal "Foo", t.name
  end
  
  def test_responds_to_needed_methods
    t = Tracksperanto::Tracker.new
    assert_respond_to t, :name
    assert_respond_to t, :each
    assert_respond_to t, :keyframes
  end
  
  def test_properly_ignores_flattening
    t = []
    t << Tracksperanto::Tracker.new(:name => "Abc")
    t[-1].keyframe! :abs_x => 12, :abs_y => 23, :frame => 1
    t[-1].keyframe! :abs_x => 13, :abs_y => 24, :frame => 2
    
    t << Tracksperanto::Tracker.new(:name => "Cde")
    t[-1].keyframe! :abs_x => 12, :abs_y => 23, :frame => 1
    t[-1].keyframe! :abs_x => 13, :abs_y => 24, :frame => 2
    
    assert_kind_of Tracksperanto::Tracker, t.flatten[0]
    assert_equal 2, t.flatten.length
  end
  
  def test_supports_hash_init
    assert_equal "Foo", Tracksperanto::Tracker.new(:name => "Foo").name
  end
  
  def test_supports_hash_init_with_keyframes
    assert_equal [1,2], Tracksperanto::Tracker.new(:keyframes => [1,2]).keyframes
  end
  
  def test_supports_array_methods
    t = Tracksperanto::Tracker.new(:keyframes => [1,2])
    assert_equal [1,2], t.to_a
    assert_equal 2, t.length
    t.push(3)
    assert_equal 3, t.length
    assert_equal [1,2,3], t.to_a
  end
    
  def test_inspect
    t = Tracksperanto::Tracker.new(:name => "FooTracker")
    assert_equal '<T "FooTracker" with 0 keyframes>', t.inspect
  end
  
  def test_ensure_tracker_forbids_spaces_in_names
    t = Tracksperanto::Tracker.new(:name => "Mary had a \n \t little lamb")
    assert_equal "Mary_had_a_little_lamb", t.name
  end
  
  def test_enumerates_keyframe_values_and_returns_length
    t = Tracksperanto::Tracker.new(:keyframes => [:a, :b])
    assert_equal [:a, :b], t.map{|e| e}
    assert_equal 2, t.length
    assert_equal :a, t[0]
  end
  
end