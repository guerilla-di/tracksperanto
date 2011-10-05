require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestBufferingReader < Test::Unit::TestCase
  def test_reads_once
    s = StringIO.new("This is a string")
    
    reader = Tracksperanto::BufferingReader.new(s)
    assert_equal "T", reader.read(1)
    assert_equal "h", reader.read(1)
    assert_equal "is is", reader.read(5)
    assert !reader.eof?
    assert_equal 7, reader.pos
    reader.rewind
    assert_equal 0, reader.pos
  end
  
  def test_reads_in_bulk
    s = StringIO.new("This is a string")
    
    reader = Tracksperanto::BufferingReader.new(s)
    assert_equal "This is a string", reader.read(2048)
    assert reader.eof?
    assert_equal 16, reader.pos
    
  end
end