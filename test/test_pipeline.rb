# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestPipeline < Test::Unit::TestCase
  
  def create_stabilizer_file
    @stabilizer = "input.stabilizer"
    trackers = %w( Foo Bar Baz).map do | name |
      t = Tracksperanto::Tracker.new(:name => name)
      t.keyframe!(:frame => 3, :abs_x => 100, :abs_y => 200)
      t.keyframe!(:frame => 4, :abs_x => 200, :abs_y => 120)
      t.keyframe!(:frame => 5, :abs_x => 210, :abs_y => 145)
      t
    end
    
    File.open(@stabilizer, "wb") do | f |
      exporter = Tracksperanto::Export::FlameStabilizer.new(f)
      exporter.just_export(trackers, 720, 576)
    end
  end
  
  def test_supports_block_init
    pipeline = Tracksperanto::Pipeline::Base.new(:tool_tuples => [:a, :b])
    assert_equal [:a, :b], pipeline.tool_tuples
  end
  
  def test_run_with_autodetected_importer_and_size_without_progress_block
    in_temp_dir do
      create_stabilizer_file
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_nothing_raised { pipeline.run(@stabilizer) }
      assert_equal 3, pipeline.converted_points
      assert_equal 9, pipeline.converted_keyframes, "Should report conversion of 9 keyframes"
    end
  end
  
  def test_run_with_error_picks_up_known_snags_from_importer
    in_temp_dir do
      create_stabilizer_file
      pipeline = Tracksperanto::Pipeline::Base.new
      flexmock(Tracksperanto::Import::ShakeScript).should_receive(:known_snags).times(1)
      assert_raise(Tracksperanto::Pipeline::NoTrackersRecoveredError) do
        pipeline.run(@stabilizer, :importer => "ShakeScript", :width => 2910, :height => 1080)
      end
    end
  end
  
  def test_run_with_autodetected_importer_and_size_with_progress_block
    in_temp_dir do
      create_stabilizer_file
      processing_log = ""
      accum = lambda do | percent, message |
        processing_log << ("%d -> %s\n" % [percent, message])
      end
    
      pipeline = Tracksperanto::Pipeline::Base.new(:progress_block => accum)
      assert_nothing_raised { pipeline.run(@stabilizer) }
      assert processing_log.include?("Parsing the file")
      assert processing_log.include?("Parsing channel \"tracker1/ref/y\"")
    end
  end
  
  def test_run_returns_the_number_of_trackers_and_keyframes_processed
    in_temp_dir do
      create_stabilizer_file
      pipeline = Tracksperanto::Pipeline::Base.new
      result = pipeline.run(@stabilizer)
      assert_equal [3, 9], result
    end
  end

  def test_run_crashes_with_empty_file
    in_temp_dir do
      empty_file_path = "input_empty.stabilizer"
      f = File.open(empty_file_path, "w"){|f| f.write('') }
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_raise(Tracksperanto::Pipeline::EmptySourceFileError) { pipeline.run(empty_file_path) }
    end
  end
  
  def test_run_crashes_with_no_trackers
    in_temp_dir do
      empty_file_path = "input_empty.stabilizer"
      f = File.open(empty_file_path, "w"){|f| f.write('xx') }
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_raise(Tracksperanto::Pipeline::NoTrackersRecoveredError) { pipeline.run(empty_file_path) }
    end
  end
  
  def test_tool_initialization_from_tuples
    in_temp_dir do
      create_stabilizer_file
    
      pipeline = Tracksperanto::Pipeline::Base.new
      pipeline.tool_tuples = [
        ["Bla", {:foo=> 234}]
      ]
    
      mock_mux = flexmock("MUX")
      mock_lint = flexmock("LINT")
      flexmock(Tracksperanto::Export::Mux).should_receive(:new).and_return(mock_mux)
      flexmock(Tracksperanto::Tool::Lint).should_receive(:new).with(mock_mux).and_return(mock_lint)

      m = flexmock("tool object")
      mock_tool_class = flexmock("tool class")
    
      flexmock(Tracksperanto).should_receive(:get_tool).with("Bla").once.and_return(mock_tool_class)
      mock_tool_class.should_receive(:new).with(mock_lint, {:foo => 234}).once
    
      assert_raise(NoMethodError) { pipeline.run(@stabilizer) }
    end
  end
  
  def test_run_with_autodetected_importer_that_requires_size
    in_temp_dir do
      FileUtils.cp( File.dirname(__FILE__) + "/import/samples/shake_script/four_tracks_in_one_stabilizer.shk", "input.shk")
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_raise(Tracksperanto::Pipeline::DimensionsRequiredError) { pipeline.run("input.shk") }
    end
  end
  
  def test_run_with_autodetected_importer_that_requires_size_when_size_supplied
    in_temp_dir do
      FileUtils.cp( File.dirname(__FILE__) + "/import/samples/shake_script/four_tracks_in_one_stabilizer.shk", "input.shk")
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_nothing_raised { pipeline.run("input.shk", :width => 720, :height => 576) }
    end
  end
  
  def test_run_with_overridden_importer_and_no_size
    in_temp_dir do
      FileUtils.cp( File.dirname(__FILE__) + "/import/samples/shake_script/four_tracks_in_one_stabilizer.shk", "input.shk")
      pipeline = Tracksperanto::Pipeline::Base.new
      num_exporters = Tracksperanto.exporters.length
      assert_nothing_raised { pipeline.run("input.shk", :importer => "ShakeScript", :width => 720, :height => 576) }
      assert_equal num_exporters, Dir.glob("input_*").length, "#{num_exporters} files should be present for the input and outputs"
    end
  end
  
  def test_run_with_overridden_importer_and_size_for_file_that_would_be_recognized_differently
    in_temp_dir do
      FileUtils.cp( File.dirname(__FILE__) + "/import/samples/shake_script/four_tracks_in_one_stabilizer.shk", "input.stabilizer")
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_nothing_raised { pipeline.run("input.stabilizer", :importer => "ShakeScript", :width => 720, :height => 576) }
    end
  end
  
  def test_run_with_unknown_format_raises
    in_temp_dir do
      File.open("input.txt", "w"){|f| f.write("foo") }
    
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_raise(Tracksperanto::Pipeline::UnknownFormatError) { pipeline.run("input.txt") }
      assert_raise(Tracksperanto::Pipeline::UnknownFormatError) { pipeline.run("input.txt", :width => 100, :height => 100) }
      assert_raise(Tracksperanto::Pipeline::DimensionsRequiredError) { pipeline.run("input.txt", :importer => "Syntheyes") }
    end
  end
  
  def test_importing_file_with_trackers_of_zero_length_does_not_accumulate_any_trackers
    in_temp_dir do
      pft_with_empty_trackers = File.dirname(__FILE__) + "/import/samples/pftrack5/empty_trackers.2dt"
      i = Tracksperanto::Import::PFTrack.new(:io => File.open(pft_with_empty_trackers), :width => 1920, :height => 1080)
      tks = i.to_a
      assert_equal 3, tks.length
      assert_equal 0, tks[0].length, "The tracker should have 0 keyframes for this test to make sense"
    
      FileUtils.cp(pft_with_empty_trackers, "input_empty.2dt")
    
      pipeline = Tracksperanto::Pipeline::Base.new
      num_t, num_k = pipeline.run("input_empty.2dt", :width => 1920, :height => 1080)
      assert_equal 1, num_t, "Only one tracker should have been sent through the export"
    end
  end
  
  def test_run_with_overridden_importer_and_size
    in_temp_dir do
      FileUtils.cp( File.dirname(__FILE__) + "/import/samples/3de_v4/3de_export_cube.txt", "input.txt")
      pipeline = Tracksperanto::Pipeline::Base.new
      assert_raise(Tracksperanto::Pipeline::DimensionsRequiredError) { pipeline.run("input.txt", :importer => "Equalizer4") }
      assert_nothing_raised { pipeline.run("input.txt", :importer => "Equalizer4", :width => 720, :height => 576) }
    end
  end
  
end
