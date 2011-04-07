require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestAccumulator < Test::Unit::TestCase
  
  def test_accumulator_saves_objs
    a = Tracksperanto::Accumulator.new
    values = [3, {:foo => "bar"}, "foo"]
    values.map(&a.method(:push))
    
    assert_equal 3, a.size
    assert_equal values, a.map{|e| e }, "Should return the same elements from the storage"
  end
  
  def test_accumulator_saves_shitload_of_objs
    a = Tracksperanto::Accumulator.new
    50_000.times { a.push("A string" => rand) }
    assert_equal 50_000, a.size
  end
  
  def test_accumulator_saves_shitload_of_objs
    a = Tracksperanto::Accumulator.new
    4.times { a.push("A \tstring") }
    a.each {|e| assert_equal "A \tstring", e }
  end
  
  def test_accumulator_empty
    a = Tracksperanto::Accumulator.new
    assert a.empty?
    a.push(1)
    assert !a.empty?
  end
  
  def test_accumulator_supports_nested_iteration
    a = Tracksperanto::Accumulator.new
    ("A".."Z").each{|e| a << e}
    
    accumulated = []
    seen_g = false
    a.each do | first_level |
      if first_level == "G"
        seen_g = true
        # Force a nested iteration and break it midway
        a.each do | second_level |
          accumulated.push(second_level)
          break if second_level == "E"
        end
      elsif seen_g
        assert_equal "H", first_level
        return
      end
    end
  end
  
  def test_clear_calls_close_on_buffer
    io = Tracksperanto::BufferIO.new
    flexmock(io).should_receive(:close!)
    flexmock(Tracksperanto::BufferIO).should_receive(:new).once.and_return(io)
    
    a = Tracksperanto::Accumulator.new
    40.times { a.push("A string" => rand) }
    assert_equal 40, a.size
    a.clear
    assert_equal 0, a.size
  end
end