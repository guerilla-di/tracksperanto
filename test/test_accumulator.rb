require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestAccumulator < Test::Unit::TestCase
  
  def test_accumulator_saves_objs
    a = Tracksperanto::Accumulator.new
    values = [3, {:foo => "bar"}, "foo"]
    values.map(&a.method(:push))
    
    assert_equal 3, a.length
    assert_equal values, a.map{|e| e }, "Should return the same elements from the storage"
  end
  
  def test_accumulator_saves_shitload_of_objs
    a = Tracksperanto::Accumulator.new
    50_000.times { a.push("A string" => rand) }
    assert_equal 50_000, a.length
  end
end