require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestBufferingReader < Test::Unit::TestCase
  def test_reads_once
    s = StringIO.new("This is a string")
    
    reader = Tracksperanto::BufferingReader.new(s)
    assert_equal "T", reader.read_one_byte
    assert_equal "h", reader.read_one_byte
    assert !reader.data_exhausted?
  end
  
  def test_reads_set_buffer_size
    s = StringIO.new("abcd")
    flexmock(s).should_receive(:read).with(4).once.and_return("abcd")
    reader = Tracksperanto::BufferingReader.new(s, 4)
    reader.read_one_byte
  end
  
  def test_reads_in_10kb_chunks_by_default
    s = StringIO.new("abcd")
    flexmock(s).should_receive(:read).with(10240).once.and_return("abcd")
    reader = Tracksperanto::BufferingReader.new(s)
    reader.read_one_byte
  end
  
  def test_eof_with_empty
    s = StringIO.new
    reader = Tracksperanto::BufferingReader.new(s)
    assert s.eof?
  end
  
  def test_eof_with_io_at_eof
    s = StringIO.new("foo")
    s.read(3)
    reader = Tracksperanto::BufferingReader.new(s)
    assert reader.data_exhausted?
  end
  
  def test_eof_with_string_to_size
    s = "Foobarboo another"
    s = StringIO.new(s)
    reader = Tracksperanto::BufferingReader.new(s, 1)
    s.length.times { reader.read_one_byte }
    assert reader.data_exhausted?
  end
end