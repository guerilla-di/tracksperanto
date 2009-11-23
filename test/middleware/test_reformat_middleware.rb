require File.dirname(__FILE__) + '/../helper'

class ReformatMiddlewareTest < Test::Unit::TestCase
  def test_inherits_and_thus_complies
    assert Tracksperanto::Middleware::Reformat.ancestors.include?(Tracksperanto::Middleware::Base)
  end
  
  def test_default_params_zeroed
    receiver = flexmock
    m = Tracksperanto::Middleware::Reformat.new(receiver)
    assert_equal 0, m.width
    assert_equal 0, m.height
  end
  
  def test_reformat_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Middleware::Reformat.new(receiver, :width => 1920, :height => 1080)
    assert_equal 1920, m.width
    assert_equal 1080, m.height
  end
  
  def test_reformat_bypasses_methods_and_sets_aspect
    upscale_h =  2.66666666666667
    upscale_v =  1.875
    
    receiver = flexmock
    receiver.should_receive(:start_export).once.with(1920,1080)
    receiver.should_receive(:end_export).once
    
    m = Tracksperanto::Middleware::Reformat.new(receiver, :width => 1920, :height => 1080)
    
    m.start_export(720, 576)
    m.end_export
  end
end