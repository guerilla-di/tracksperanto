# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestBlockInit < Test::Unit::TestCase
  
  class Settable
    include Tracksperanto::BlockInit
    
    attr_accessor :foo, :bar
    
    private
    def privatized=(something)
    end
  end
  
  def test_block_init_with_hash
    s = Settable.new(:foo => "x", :bar => "y")
    assert_equal "x", s.foo
    assert_equal "y", s.bar
  end
  
  def test_block_init_with_hash_raises_on_unknown_attribute
    assert_raise(NoMethodError) { Settable.new(:nonexistent => true) }
  end
  
  def test_block_init_with_block_yields_the_object
    within_blk = nil
    s = Settable.new do | f |
      within_blk = f
      f.foo = "x"
    end
    
    assert_equal s, within_blk, "Should have yielded the object to the blk"
    assert_equal "x", s.foo
  end

  def test_block_init_attributes_overwrite_hash_attributes
    s = Settable.new(:foo => "bar") { |f| f.foo = "x" }
    assert_equal "x", s.foo
  end
  
  if RUBY_VERSION > '1.9'
    def test_block_init_uses_public_send
      assert_raise(NoMethodError) { Settable.new(:privatized => true) }
    end
  end
  
  
end