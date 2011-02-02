require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class EqualizerImportTest < Test::Unit::TestCase
  DELTA = 0.001
  
  def test_introspects_properly
    i = Tracksperanto::Import::Equalizer4
    assert_equal "3DE v4 point export file", i.human_name
    assert !i.autodetects_size?
  end
  
  def test_parsing_from_importable
    fixture = File.open(File.dirname(__FILE__) + '/samples/3de_v4/3de_export_cube.txt')
    
    parser = Tracksperanto::Import::Equalizer4.new
    parser.width = 1024
    parser.height = 512
    trackers = parser.parse(fixture)
    
    assert_equal 8, trackers.length
    
    first_t = trackers[0]
    assert_equal "01", first_t.name
    assert_equal 61, first_t.length
    
    first_kf = first_t[0]
    assert_in_delta 407.384758225105315, first_kf.abs_x, DELTA
    assert_in_delta 232.449011732690479, first_kf.abs_y, DELTA
    assert_equal 39, first_kf.frame
  end
end