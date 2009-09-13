require File.dirname(__FILE__) + '/helper'

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
  
  def test_supports_hash_init
    assert_equal "Foo", Tracksperanto::Tracker.new(:name => "Foo").name
  end
  
  def test_inspect
    t = Tracksperanto::Tracker.new(:name => "FooTracker")
    assert_equal '<T "FooTracker" with 0 keyframes>', t.inspect
  end
  
  def test_enumerates_keyframe_values_and_returns_length
    t = Tracksperanto::Tracker.new(:keyframes => [:a, :b])
    assert_equal [:a, :b], t.map{|e| e}
    assert_equal 2, t.length
    assert_equal :a, t[0]
  end
  
  def test_tracker_dsl
    t = Tracksperanto.tracker("SomeFoo") do | t |
      t.key(:frame => 0, :abs_x => 123, :abs_y => 456)
    end
    
    assert_kind_of Tracksperanto::Tracker, t
    assert_equal "SomeFoo", t.name
    assert_equal 1, t.length
    assert_equal 123.0, t[0].abs_x
    assert_equal 456.0, t[0].abs_y
    assert_equal 0, t[0].frame
  end
end