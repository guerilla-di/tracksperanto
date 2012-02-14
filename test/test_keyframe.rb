# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestKeyframe < Test::Unit::TestCase
  def test_supports_block_init
    keyframe = Tracksperanto::Keyframe.new do |k| 
      k.frame = 0
      k.abs_x = 10.3
      k.abs_y = 12.5
    end
    
    assert_equal 0, keyframe.frame
    assert_equal 10.3, keyframe.abs_x
    assert_equal 12.5, keyframe.abs_y
  end
  
  def test_sorts_on_frame
    kf = Tracksperanto::Keyframe.new(:frame => 4, :abs_x => 10, :abs_y => 12.0)
    kf2 = Tracksperanto::Keyframe.new(:frame => 2, :abs_x => 10, :abs_y => 12.0)
    assert_equal [kf2, kf], [kf, kf2].sort
  end
  
  def test_compares_equally_with_same_values
    kf = Tracksperanto::Keyframe.new(:frame => 2, :abs_x => 10, :abs_y => 12.0)
    kf2 = Tracksperanto::Keyframe.new(:frame => 2, :abs_x => 10, :abs_y => 12.0)
    assert_equal kf, kf2
  end
  
  def test_dup
    kf = Tracksperanto::Keyframe.new(:frame => 2, :abs_x => 10, :abs_y => 12.0)
    kf2 = kf.dup
    kf2.frame = 15
    assert_not_equal kf, kf2
  end
  
  def test_inspect
    kf = Tracksperanto::Keyframe.new(:frame => 0, :abs_x => 10, :abs_y => 12.0)
    assert_equal "#< 10.0x12.0 @0 ~0.00) >", kf.inspect
  end
  
  def test_frame_translated_to_int
    kf = Tracksperanto::Keyframe.new {|k|  k.frame = '0' }
    assert_equal 0, kf.frame
  end
  
  def test_residual_defaults_to_zero
    kf = Tracksperanto::Keyframe.new
    assert_in_delta 0.0, kf.residual, 0.01
  end

  def test_abs_x_abs_y_translated_to_float
    kf = Tracksperanto::Keyframe.new {|k|  k.abs_x = '123.45678'; k.abs_y = '321.45678' }
    assert_kind_of Float, kf.abs_x
    assert_kind_of Float, kf.abs_y
  end

end
