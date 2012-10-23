# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestUVCoords < Test::Unit::TestCase
  include Tracksperanto::UVCoordinates
  
  DELTA = 0.001
  
  def test_from_uv
    assert_in_delta 719.5, convert_from_uv(1.0, 720), DELTA
    assert_in_delta 0.5, convert_from_uv(-1.0, 720), DELTA
  end
  
  def test_from_uv_with_small_values
    assert_in_delta 0.5, convert_from_uv(-1.0, 16), DELTA
    assert_in_delta 15.5, convert_from_uv(1.0, 16), DELTA
  end
  
  def test_to_uv_with_small_values
    assert_in_delta -1.0, convert_to_uv(0.5, 16), DELTA
    assert_in_delta 1.0, convert_to_uv(15.5, 16), DELTA
  end
  
  
  def test_to_uv
    assert_in_delta 1.0, convert_to_uv(719.5, 720), DELTA
    assert_in_delta -1.0, convert_to_uv(0.5, 720), DELTA
  end
end
