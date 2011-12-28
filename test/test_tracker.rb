require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TrackerTest < Test::Unit::TestCase
  
  def setup
    @keyframes = [
      Tracksperanto::Keyframe.new(:frame => 15, :abs_x => 123, :abs_y => 456),
      Tracksperanto::Keyframe.new(:frame => 8, :abs_x => 678, :abs_y => 901),
      Tracksperanto::Keyframe.new(:frame => 1, :abs_x => 342, :abs_y => 312),
    ]
  end
  
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
    kfs = Tracksperanto::Keyframe.new(:frame => 1, :abs_x => 123, :abs_y => 456)
    assert_equal [kfs], Tracksperanto::Tracker.new(:keyframes => [kfs]).keyframes
  end
  
  def test_supports_array_methods
    kfs = Tracksperanto::Keyframe.new(:frame => 1, :abs_x => 123, :abs_y => 456)
    t = Tracksperanto::Tracker.new(:keyframes => [kfs])
    
    assert_equal [kfs], t.to_a
    assert_equal 1, t.length
  end
  
  def test_push
    kf = Tracksperanto::Keyframe.new(:frame => 1, :abs_x => 123, :abs_y => 456)
    t = Tracksperanto::Tracker.new(:name => "Test")
    t.push(kf)
    assert_equal 1, t.length
    
    kf = Tracksperanto::Keyframe.new(:frame => 1, :abs_x => 333, :abs_y => 456)
    assert_raise(Tracksperanto::Tracker::Dupe) do
      t.push(kf)
    end
  end
  
  def test_set
    flunk
  end
  
  def test_bracket_subscript
    t = Tracksperanto::Tracker.new(:name => "Shmoo", :keyframes => @keyframes)
    kf = t[0]
    assert_equal kf, @keyframes[-1], "Keyframe at 1 should be returned"
  end
  
  def test_at_frame
    flunk
  end
  
  def test_keyframes_assignment_overwrites
    flunk
  end
  
  def test_empty?
    t = Tracksperanto::Tracker.new(:name => "Test")
    assert t.empty?
    
    t = Tracksperanto::Tracker.new(:name => "Test")
    t.keyframe! :frame => 10, :abs_x => 123
    assert !t.empty?
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