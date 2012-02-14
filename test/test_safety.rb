# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class SafetyTest < Test::Unit::TestCase
  class Testable
    include Tracksperanto::Safety
    attr_accessor :foo, :bar
    safe_reader :foo, :bar
  end
  
  def test_safe_reader_raises_with_no_ivar
    t = Testable.new
    assert_raise(RuntimeError) { t.foo }
  end

  def test_safe_reader_does_not_raise_with_value_assigned
    t = Testable.new
    t.foo = 123
    assert_nothing_raised { assert_equal 123, t.foo }
  end
end
