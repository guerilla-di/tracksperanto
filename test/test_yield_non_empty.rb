require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestYieldNonEmpty < Test::Unit::TestCase
  
  def test_yield_non_empty
    arr = ["", "a"]
    assert_equal ["a"], Tracksperanto::YieldNonEmpty.new(arr).to_a
  end
  
end
