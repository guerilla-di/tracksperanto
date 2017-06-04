require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class Equalizer3ImportTest < Test::Unit::TestCase
  DELTA = 0.001
  
  def test_introspects_properly
    i = Tracksperanto::Import::Equalizer3
    assert_equal "3DE v3 point export file", i.human_name
    assert i.autodetects_size?
  end

  
  def test_parsing_from_importable
    fixture = File.open(File.dirname(__FILE__) + '/samples/3de_v3/3de_export_v3.txt')
    
    parser = Tracksperanto::Import::Equalizer3.new(:io => fixture)
    trackers = parser.to_a
    
    assert_equal 2048, parser.width
    assert_equal 778, parser.height
    
    assert_equal 39, trackers.length
    
    first_t = trackers[0]
    assert_equal "03", first_t.name
    assert_equal 43, first_t.length
    
    first_kf = first_t[0]
    assert_equal 22, first_kf.frame
    assert_in_delta 71.7889, first_kf.abs_x, DELTA
    assert_in_delta 481.708, first_kf.abs_y, DELTA
  end
end
