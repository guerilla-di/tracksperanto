require File.dirname(__FILE__) + '/helper'

class TestExtio < Test::Unit::TestCase
  def e(st)
    Tracksperanto::ExtIO.new(StringIO.new(st))
  end
  
  def test_gets
    assert_equal "Mary had\n", e("Mary had\n").gets
  end

  def test_gets_and_strip
    assert_equal "Mary had", e("Mary had\na little lamb\n").gets_and_strip
  end

  def test_gets_and_strip_at_end
    s = e("Mary had\na little lamb\n")
    s.gets_and_strip
    s.gets_and_strip
    
    assert_nil s.gets_and_strip
  end
  
  def test_gets_non_empty
    s = e("\n\n\n\nfoo")
    assert_equal "foo", s.gets_non_empty
  end
end