require File.dirname(__FILE__) + '/../helper'

class ReformatMiddlewareTest < Test::Unit::TestCase
  def test_inherits_and_thus_complies
    assert Tracksperanto::Middleware::Reformat.ancestors.include?(Tracksperanto::Middleware::Scaler)
  end
  
  def test_default_params_set_to_nil
    receiver = flexmock
    m = Tracksperanto::Middleware::Reformat.new(receiver)
    assert_equal nil, m.width
    assert_equal nil, m.height
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
    
    m = Tracksperanto::Middleware::Reformat.new(receiver, :width => 1920, :height => 1080)
    
    m.start_export(720, 576)
    assert_in_delta upscale_h, m.send(:x_factor), 0.00001, "The middleware should have configured the x factor on export start"
    assert_in_delta upscale_v, m.send(:y_factor), 0.00001, "The middleware should have configured the y factor on export start"
  end
end