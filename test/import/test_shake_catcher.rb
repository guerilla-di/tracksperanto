# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class ShakeCatcherTest < Test::Unit::TestCase
  C = Tracksperanto::ShakeGrammar::Catcher
  
  def at(at, v)
    C::At.new(at, v)
  end
  
  def test_hould_catch_simple_funcall
    k = Class.new(C) do
      def foofunc(a, b, c)
        "#{a.inspect} #{b.inspect} #{c.inspect}"
      end
    end
    tree = parse("FooFunc(1, 2, 3)", k)
    assert_equal [[:retval, "1 2 3"]], tree
  end
  
  def test_uknown_funcalls
    k = Class.new(C)
    tree = parse("OuterFunc(InnerFunc(15)", k)
    assert_equal [[:unknown_func]], tree
    
    tree = parse("OuterFunc(15);", k)
    assert_equal [[:unknown_func]], tree
  end
  
  def test_nested_funcalls
    k = Class.new(C) do
      def outerfunc(a)
        a * 2
      end
      
      def innerfunc(b)
        b * 10
      end
    end
    
    tree = parse("OuterFunc(InnerFunc(15)", k)
    assert_equal [[:retval, 300]], tree
  end
  
  def test_hermite_funcall_with_array_ats
    k = Class.new(C) do
      def hermite(first_arg, *keyframes)
        keyframes
      end
    end
    
    tree = parse('Hermite(0,[1379.04,-0.02,-0.02]@1,[1379.04,-0.03,-0.03]@2)', k)
    assert_equal [[:retval, [at(1, [1379.04, -0.02, -0.02]), at(2, [1379.04, -0.03, -0.03])]]],  tree
  end
  
  def test_linear_funcall
    k = Class.new(C) do
      def linear(first_arg, *keyframes)
        123
      end
    end
    
    tree = parse('Linear(0,591.702@1,591.452@2,591.202@3,590.733@4,590.202@5,589.421@6,589.249@7)', k)
    assert_equal [[:retval, 123]],  tree
  end
  
  def test_nested_funcalls_with_array_return
    k = Class.new(C) do
      def outerfunc(a)
        a * 2
      end
      
      def innerfunc(b)
        [b, b* 2, b* 3]
      end
    end
    
    tree = parse("OuterFunc(InnerFunc(15)", k)
    assert_equal [[:retval, [15, 30, 45, 15, 30, 45]]], tree
  end
  
  def parse(s, klass)
    s = StringIO.new(s) unless s.respond_to?(:read)
    klass.new(s).stack
  end
end
