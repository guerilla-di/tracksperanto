# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class BoujouImportTest < Test::Unit::TestCase
  DELTA = 0.1
  
  def test_introspects_properly
    i = Tracksperanto::Import::Boujou
    assert_equal "Boujou feature tracks export", i.human_name
    assert !i.autodetects_size?
  end
  
  def test_parsing_from_fixture
     fixture = File.open(File.dirname(__FILE__) + '/samples/boujou_features_text/boujou_txt_export.txt')
     
     parser = Tracksperanto::Import::Boujou.new(:io => fixture, :width => 2560, :height => 1200)
     trackers = parser.to_a
     
     assert_equal 21, trackers.length
     
     tracker1 = trackers[1]
     
     assert_equal "tracker1", tracker1.name
     assert_equal 132, tracker1.length
     
     kf = tracker1[0]
     assert_in_delta 306.906, kf.abs_x, DELTA
     assert_in_delta 39.79, kf.abs_y, DELTA
  end
end
