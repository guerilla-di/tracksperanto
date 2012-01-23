# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestBufferIO < Test::Unit::TestCase
  
  def test_write_in_mem_has_a_stringio
    io = Tracksperanto::BufferIO.new
    9000.times { io.write("a") }
    assert_kind_of StringIO, io.__getobj__
    assert_nothing_raised { io.close! }
  end
  
  def test_write_larger_than_max_swaps_tempfile
    io = Tracksperanto::BufferIO.new
    io.write("a" * 6_000_001)
    f = io.__getobj__
    assert_kind_of Tempfile, f
    f.rewind
    assert_equal 6_000_001, f.read.length
    flexmock(f).should_receive(:close!).once
    io.close!
  end
  
  def test_to_file_forces_immediate_promotion_to_file
    io = Tracksperanto::BufferIO.new
    io.write("a" * 3000)
    assert_equal 3000, io.pos
    assert !io.file_backed?
    
    f = io.to_file
    assert_equal 3000, f.pos
    assert f.file_backed?
  end
end
