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
  end
end