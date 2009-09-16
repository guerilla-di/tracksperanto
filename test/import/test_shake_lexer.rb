require File.dirname(__FILE__) + '/../helper'

class ShakeLexerTest < Test::Unit::TestCase
  P = File.dirname(__FILE__) + "/samples/shake_tracker_nodes.shk"
  def test_parse_single_cmt
    cmt = " // Mary had a little lamb"
    s = parse(cmt)
    assert_equal [[:comment, " Mary had a little lamb"]], s
  end
  
  def test_parse_two_line_cmt
    cmt = [" // Mary had a little lamb", " // Old McDonald had a farm"].join("\n\n\n\n\n\n")
    s = parse(cmt)
    assert_equal [[:comment, " Mary had a little lamb"], [:comment, " Old McDonald had a farm"]], s
  end
  
  def test_parse_funcall
    s = parse ' DoFoo(1, 2, 3, "Welcome!\"\"");   '
    assert_equal [[:funcall, "DoFoo", [:atom_i, 1], [:atom_i, 2], [:atom_i, 3], [:atom_c, "Welcome!\"\""]]], s
  end
  
  def test_parse_nested_funcall
    s = parse ' DoFoo(1, Foo(4));'
    assert_equal [[:funcall, "DoFoo", [:atom_i, 1], [:funcall, "Foo", [:atom_i, 4]]]], s
  end
  
  def test_parse_funcall_with_valueats
    s = parse 'Linear(0,716.08@1,715.846@2,715.518@3,715.034@4,714.377@5)'
    assert_equal(
      [[:funcall, "Linear", [:atom_i, 0], [:atom_at, 716.08, 1], [:atom_at, 715.846, 2], 
        [:atom_at, 715.518, 3], [:atom_at, 715.034, 4], [:atom_at, 714.377, 5]]], s
    )
  end
  
  def test_parse_hermite_valuats_with_arrays
    # Hermite curves use array args
    s = parse 'Hermite(0,[-64,98.33,98.33]@1,[50,97.29,97.29]@4)'
  end
  
  def test_parse_varassign
    s = parse 'Foo = Blur(Foo, 1, 2, 3);'
    assert_equal [[:var, "Foo"], [:eq], [:funcall, "Blur", [:atom, "Foo"], [:atom_i, 1], [:atom_i, 2], [:atom_i, 3]]], s
  end
  
#  def test_parse_whole_file_does_not_raise
#    f = File.open(P)
#    assert_nothing_raised { parse(f) }
#  end
  
  def parse(s)
    s = StringIO.new(s) unless s.respond_to?(:read)
    Tracksperanto::Import::ShakeScript::Lexer.new(s).stack
  end
end