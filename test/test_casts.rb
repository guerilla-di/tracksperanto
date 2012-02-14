# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class CastsTest < Test::Unit::TestCase
  D = 0.0001
  class Testable
    include Tracksperanto::Casts
    attr_accessor :vanilla, :str_attr, :int_attr, :float_attr
    cast_to_string :str_attr
    cast_to_int :int_attr
    cast_to_float :float_attr
  end
  
  class Junk
    def to_s
      "Random"
    end
  end
  
  def test_cast_to_float
    t = Testable.new
    assert_kind_of Float, t.float_attr, "Uninitialized float attr should be a float"
    assert_in_delta 0, t.float_attr, D
    
    t.float_attr = "3"
    assert_kind_of Float, t.float_attr
    assert_in_delta 3.0, t.float_attr, D
    
    t.float_attr = "a"
    assert_kind_of Float, t.float_attr
    assert_in_delta 0, t.float_attr, D
  end

  def test_cast_to_int
    t = Testable.new
    
    assert_equal 0, t.int_attr, "Uninitialized int attr should be an int"
    
    t.int_attr = "3.1"
    assert_kind_of Fixnum, t.int_attr
    assert_equal 3, t.int_attr
    
    t.float_attr = 3.1
    assert_kind_of Fixnum, t.int_attr
    assert_equal 3, t.int_attr
  end
  
  def test_cast_to_string
    t = Testable.new
    
    assert_equal '', t.str_attr
    t.str_attr = 3.123
    assert_equal "3.123", t.str_attr
    
    t.str_attr = Junk.new
    assert_equal "Random", t.str_attr
  end
end
