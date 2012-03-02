# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class SyntheyesAllPathsImportTest < Test::Unit::TestCase
  DELTA = 0.001 # our SynthEyes sample is somewhat inaccurate :-P
  
  def test_introspects_properly
    i = Tracksperanto::Import::SyntheyesAllTrackerPaths
    assert_equal "Syntheyes \"All Tracker Paths\" export .txt file", i.human_name
    assert !i.autodetects_size?
  end
  
  def test_parsing_from_importable
    fixture = File.open(File.dirname(__FILE__) + '/samples/syntheyes_all_tracker_paths/shot06_2dTracks.txt')
    i = Tracksperanto::Import::SyntheyesAllTrackerPaths.new(:io => fixture, :width => 2560, :height => 1080).to_a
    
  end
end
