require File.dirname(__FILE__) + '/../helper'

class ShiftMiddlewareTest < Test::Unit::TestCase
  def test_shift_supports_hash_init
    receiver = flexmock
    m = Tracksperanto::Middleware::Flip.new(receiver, :enabled => true)
  end
  
  def test_shift_bypasses_methods
    receiver = flexmock
    receiver.should_receive(:export_point).once.with(1, 123, 95, 0)
    receiver.should_receive(:export_point).once.with(1, -123, 95, 0)
    
    m = Tracksperanto::Middleware::Flip.new(receiver, :enabled => true)
    m.export_point(1, -123, 95, 0)
    m.enabled = false
    m.export_point(1, -123, 95, 0)
  end
  
end