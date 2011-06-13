require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class ShakeLexerTest < Test::Unit::TestCase
  P = File.dirname(__FILE__) + "/samples/shake_script/shake_tracker_nodes.shk"
  OFX_CURLY_BRACES = File.dirname(__FILE__) + "/samples/shake_script/ofx_vardefs.shk"
  L = Tracksperanto::ShakeGrammar::Lexer
  WRONG = File.dirname(__FILE__) + "/samples/flame_stabilizer/hugeFlameSetup.stabilizer"
  
  def test_raises_wrong_input_when_buffer_gets_too_large
    assert_raise(Tracksperanto::ShakeGrammar::WrongInput) do
       parse(File.open(WRONG), L)
    end
  end
  
  def test_raises_wrong_input_on_stack_size
    huge_stack = "(" * 345
    assert_raise(Tracksperanto::ShakeGrammar::WrongInput) do
       parse(StringIO.new(huge_stack), L)
    end
  end
  
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
  
  def test_parse_hermite_curve
    curve = 'Hermite(0,[1379.04,-0.02,-0.02]@1,[1379.04,-0.03,-0.03]@2)'
    s = parse(curve)
    assert_equal [
      [:funcall,
        "Hermite",
        0,
        [:value_at, 1, [:arr, [1379.04, -0.02, -0.02]]],
        [:value_at, 2, [:arr, [1379.04, -0.03, -0.03]]]
      ]
    ], s
  end
  
  def test_parse_cmt_and_unknown
    cmt = " // Mary had a little lamb\nFooBar"
    s = parse(cmt)
    assert_equal [[:comment, " Mary had a little lamb"], [:atom, "FooBar"]], s
  end
  
  def test_parse_funcall
    s = parse ' DoFoo(1, 2, 3, "Welcome!\"\"");   '
    assert_equal [[:funcall, "DoFoo", 1, 2, 3, "Welcome!\"\""]], s
  end
  
  def test_parse_nested_funcall
    s = parse ' DoFoo(1, Foo(4));'
    assert_equal [[:funcall, "DoFoo", 1, [:funcall, "Foo", 4]]], s
  end
  
  def test_parse_single_nested_funcall
    s = parse("OuterFunc(InnerFunc(15)")
    assert_equal [[:funcall, "OuterFunc", [:funcall, "InnerFunc", 15]]], s
  end
  
  def test_parse_single_funcall
    s = parse('SomeFunc(1,2,3)')
    assert_equal [[:funcall, "SomeFunc", 1, 2, 3]], s
  end
  
  def test_parse_funcall_with_valueats
    s = parse 'Linear(0,716.08@1,715.846@2,715.518@3,715.034@4,714.377@5)'
    assert_equal(
      [[
        :funcall,
        "Linear",
        0,
        [:value_at, 1, 716.08],
        [:value_at, 2, 715.846],
        [:value_at, 3, 715.518],
        [:value_at, 4, 715.034],
        [:value_at, 5, 714.377]
      ]],
    s)
  end
  
  def test_knob_expr
    s = parse "Foobar(2, 4, {{ 4 * 16 }}, 4, 1)"
    assert_equal(
      [[
        :funcall,
        "Foobar",
        2,
        4,
        :expr,
        4,
        1,
      ]],
    s)
  end
  
  def test_lexer_with_inline_comments_munged_into_arguments
    st = 'Tracker(
        0,				// preprocess enable
        10				// bluramount
    ,
    "Tracker8")'
    
    s = parse(st)
    assert_equal(
      [[
        :funcall,
        "Tracker",
        0,
        [:comment, " preprocess enable"],
        10,
        [:comment, " bluramount"],
        "Tracker8"
      ]],s)
  end
  
  def test_lexer_with_ofx_curly_braces
    s = parse(File.read(OFX_CURLY_BRACES))
    assert_equal(
      [[
        :funcall,
        "image Primatte_v2_",
        [:assign, [:vardef, "image", "ofx_Source"], 0],
        [:assign, [:vardef, "image", "ofx_BG"], 0],
        [:assign, [:vardef, "image", "ofx_Mask"], 0],
        [:assign, [:vardef, "const char *", "Poly00dral"], "0.0 0.0 0.0"],
        [:assign, [:vardef, "int", "N3D_Viewer"], 0],
        :expr
      ], [:funcall, "Foo", 2]],
    s)
  end
  
  def test_parse_funcall_with_valueats_at_negframes
    s = parse 'Linear(0,716.08@-1,715.846@2)'
    assert_equal(
      [[
        :funcall,
        "Linear",
        0,
        [:value_at, -1, 716.08],
        [:value_at, 2, 715.846],
      ]],
    s)
  end
  
  def test_parse_hermite_valuats_containing_arrays
    # Hermite curves use array args
    s = parse 'Hermite(0,[-64,98.33,98.33]@1,[50,97.29,97.29]@4)'
    ref = [[
      :funcall,
      "Hermite",
      0,
      [:value_at, 1, [:arr, [-64.0, 98.33, 98.33]]],
      [:value_at, 4, [:arr, [50, 97.29, 97.29]]]
    ]]
    assert_equal ref, s
  end
  
  def test_parse_from_start_injects_comment
    p = File.open(P){|f| f.read(1600) }
    tree = parse(p)
    assert_equal :comment, tree[0][0]
    assert_equal :comment, tree[1][0]
    assert_equal :funcall, tree[2][0]
  end
  
  def test_parse_simple_varassign
     s = parse 'Foo = 1;'
     assert_equal [[:assign, [:vardef, :image, "Foo"], 1]], s, "Note that the variable name should be escaped properly"
  end
   
  def test_parse_varassign
    s = parse 'Foo = Blur(Foo, 1, 2, 3); 1'
    assert_equal [[:assign, [:vardef, :image, "Foo"], [:funcall, "Blur", [:atom, "Foo"], 1, 2, 3]], 1], s
  end
  
  def test_parse_varassign_with_typedef
    s = parse 'curve float focal = Linear(0,2257.552@1,2257.552@2)'
    assert_equal [[:assign, [:vardef, "curve float", "focal"], [:funcall, "Linear", 0, [:value_at, 1, 2257.552], [:value_at, 2, 2257.552]]]], s
  end

  def test_parse_varassign_with_typedef_charstar
    s = parse 'char * information = "Ausgezeichnet!";'
    assert_equal [[:assign, [:vardef, "char *", "information"], "Ausgezeichnet!" ]], s
  end
  
  def test_parse_whole_file_does_not_raise
    assert_nothing_raised do
       parse(File.open(P), L)
    end
  end
    
  def parse(s, klass = L)
    s = StringIO.new(s) unless s.respond_to?(:read)
    klass.new(s).stack
  end
end