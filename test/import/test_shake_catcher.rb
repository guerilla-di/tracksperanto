require File.dirname(__FILE__) + '/../helper'

class ShakeCatcherTest < Test::Unit::TestCase
  C = Tracksperanto::Import::ShakeScript::Catcher
  def test_hould_catch_simple_funcall
    k = Class.new(C) do
      def foofunc(a, b, c)
        "#{a.inspect} #{b.inspect} #{c.inspect}"
      end
    end
    tree = parse("FooFunc(1, 2, 3)", k)
    assert_equal [[:retval, "1 2 3"]], tree
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