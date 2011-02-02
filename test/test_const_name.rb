require File.expand_path(File.dirname(__FILE__)) + '/helper'

class ConstNameTest < Test::Unit::TestCase
  
  def test_const_name
    assert_equal "Scaler", Tracksperanto::Middleware::Scaler.const_name
    assert_equal "Scaler", Tracksperanto::Middleware::Scaler.new(nil).const_name
    assert_equal "ShakeScript", Tracksperanto::Import::ShakeScript.const_name
    assert_equal "ShakeText", Tracksperanto::Export::ShakeText.const_name
  end
  
end