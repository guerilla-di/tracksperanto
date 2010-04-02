require File.dirname(__FILE__) + '/helper'

class TestProgressiveIO < Test::Unit::TestCase
  
  def e(s)
    
    # Make a mock File object from a string
    io = StringIO.new(s)
    mock_stat = flexmock(:size => s.length)
    flexmock(io).should_receive(:stat).and_return(mock_stat)
    
    Tracksperanto::ProgressiveIO.new(io)
  end
  
  def test_each
    io, messages = e("Mary\nHad\nA little\nLamb"), []
    
    io.progress_block = lambda do | offset, total |
      messages.push([offset, total])
    end
    
    lines = []
    io.each {|line|  lines.push(line) }
    assert_equal ["Mary\n", "Had\n", "A little\n", "Lamb"], lines
    assert_equal [[5, 22], [9, 22], [18, 22], [22, 22]], messages
  end
  
  def test_each_byte
    io, messages = e("123"), []
    
    io.progress_block = lambda do | offset, total |
      messages.push([offset, total])
    end
    
    bytes = []
    io.each_byte{|s| bytes << s }
    assert_equal [49, 50, 51], bytes
    assert_equal [[1, 3], [2, 3], [3, 3]], messages
  end
  
  def test_getc
    io = e("123")
    io.progress_block = lambda do | offset, total |
      assert_equal [1, 3], [offset, total]
    end
    assert_equal 49, io.getc
  end
  
  def test_gets
    io = e("Mary\nHad\nA little\nLamb")
    io.progress_block = lambda do | offset, total |
      assert_equal [5, 22], [offset, total]
    end
    assert_equal "Mary\n", io.gets
  end
  
  def test_read
    io = e("Mary\nHad\nA little\nLamb")
    io.progress_block = lambda do | offset, total |
      assert_equal [15, 22], [offset, total]
    end
    assert_equal "Mary\nHad\nA litt", io.read(15)
  end
  
  def test_readchar
    io = e("123")
    io.progress_block = lambda do | offset, total |
      assert_equal [1, 3], [offset, total]
    end
    assert_equal 49, io.readchar
  end
  
  def test_readline
    io = e("Mary\nHad\nA little\nLamb")
    io.progress_block = lambda do | offset, total |
      assert_equal [5, 22], [offset, total]
    end
    assert_equal "Mary\n", io.readline
  end
  
  def test_readlines
    io = e("Mary\nHad\nA little\nLamb")
    m = []
    io.progress_block = lambda do | offset, total |
      m.push([offset, total])
    end
    
    assert_equal ["Mary\n", "Had\n", "A little\n", "Lamb"], io.readlines
    assert_equal [[22, 22]], m
  end
  
  def test_seek
    io = e("Mary\nHad\nA little\nLamb")
    io.progress_block = lambda do | offset, total |
      assert_equal [6, 22], [offset, total]
    end
    io.seek(6)
  end
  
  def test_ungetc
    io = e("Mary\nHad\nA little\nLamb")
    m = []
    io.progress_block = lambda do | offset, total |
      m.push([offset, total])
    end
    
    io.getc
    io.ungetc(2)
    assert_equal [[1, 22], [0, 22]], m
  end
  
  def test_poseq
    io = e("Mary\nHad\nA little\nLamb")
    io.progress_block = lambda do | offset, total |
      assert_equal [2, 22], [offset, total]
    end
    io.pos = 2
  end
end