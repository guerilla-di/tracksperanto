require File.expand_path(File.dirname(__FILE__)) + '/helper'

class FlameBuilderTest < Test::Unit::TestCase
  def setup
    @s = ""
    @b = Tracksperanto::FlameBuilder.new(StringIO.new(@s))
  end
  
  def test_write_loose
    @b.write_loose!("Foo")
    assert_equal "Foo\n", @s
  end

  def test_write_tuple
    @b.write_tuple!("Foo", 3)
    assert_equal "Foo 3\n", @s
  end

  def test_write_tuple_with_true
    @b.write_tuple!("Foo", true)
    assert_equal "Foo yes\n", @s
  end

  def test_write_tuple_with_false
    @b.write_tuple!("Foo", false)
    assert_equal "Foo no\n", @s
  end
  
  def test_write_block
    @b.write_block!("Foo", 1) do | b |
      b.write_tuple!("Baz", 2)
    end
    assert_equal "Foo 1\n\tBaz 2\n\tEnd\n", @s
  end
  
  def test_write_block_with_no_arg
    @b.foo {|c| c.bar }
    assert_equal "Foo\n\tBar\n\tEnd\n", @s
  end
  
  def test_write_block_with_args
    @b.foo(:bar) {|c| c.bar }
    assert_equal "Foo bar\n\tBar\n\tEnd\n", @s
  end
  
  def test_automissing_with_values
    @b.some_key(2)
    assert_equal "SomeKey 2\n", @s
  end

  def test_automissing_with_block
    @b.some_key(2) do | b |
      b.some_subkey
    end
    assert_equal "SomeKey 2\n\tSomeSubkey\n\tEnd\n", @s
  end
  
  def test_linebreak
    @b.linebreak!(5)
    assert_equal "\n" * 5, @s
  end
  
  def test_color_hash
    @b.color_hash!(:triplet, 10, 12, 15)
    assert_equal "Triplet\n\tRed 10\n\tGreen 12\n\tBlue 15\n", @s
  end
end