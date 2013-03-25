# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'
require "set"
require "cli_test"

class TestCli < Test::Unit::TestCase
  TEMP_DIR = File.expand_path(File.dirname(__FILE__) + "/tmp")
  BIN_P = File.expand_path(File.dirname(__FILE__) + "/../bin/tracksperanto")
  
  def in_temp_dir
    Dir.mktmpdir do | where |
      FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", where + "/flm.stabilizer")
      Dir.chdir(where)
      yield(where)
    end
  end
  
  # Run the tracksperanto binary with passed options, and return [exit_code, stdout_content, stderr_content]
  def cli(commandline_arguments)
    CLITest.new(BIN_P).run(commandline_arguments)
  end
  
  def test_cli_with_no_args_produces_usage
    status, o, e = cli('')
    assert_equal 1, status
    assert_match /Also use the --help option/, e
  end
  
  def test_cli_with_nonexisting_file
    in_temp_dir do 
      status, o, e = cli("nonexisting.file")
      assert_equal 1, status
      assert_match /file does not exist/, e
    end
  end
    
  def test_basic_cli
    in_temp_dir do | d |
      status, o, e = cli("flm.stabilizer")
      assert_equal 0, status, "Should exit with a normal status (error was #{e})"
      fs = %w(. .. 
        flm.stabilizer flm_3de_v3.txt flm_3de_v4.txt flm_boujou_text.txt flm_flame.stabilizer 
        flm_matchmover.rz2 flm_mayalive.txt flm_nuke.nk flm_pftrack_2011_pfmatchit.txt flm_pftrack_v4.2dt
        flm_pftrack_v5.2dt flm_shake_trackers.txt flm_syntheyes_2dt.txt flm_flame_cornerpin.stabilizer 
        flm_tracksperanto_ruby.rb flm_mayaLocators.ma flm_createNulls.jsx flm_xsi_nulls.py flm_nuke_cam_trk_autotracks.txt flm_3dsmax_nulls.ms
      )
      assert_match /Found and converted 1 trackers with 232 keyframes\./, o, "Should have output coversion statistics"
      assert_same_set fs, Dir.entries(d)
    end
  end
  
  def test_cli_with_nonexisting_only_exporter_prints_proper_error_message
    in_temp_dir do
      status, o, e = cli("--only microsoftfuckingword flm.stabilizer")
      assert_not_equal 0, status, "Should exit with abnormal state"
      assert e.include?("Unknown exporter \"microsoftfuckingword\"")
      assert e.include?("The following export modules are available")
    end
  end
  
  def test_cli_with_nonexisting_importer_prints_proper_error_message
    in_temp_dir do
      status, o, e = cli("--from microsoftfuckingword  flm.stabilizer")
      assert_not_equal 0, status, "Should exit with abnormal state"
      assert e.include?("Unknown importer \"microsoftfuckingword\"")
      assert e.include?("The following import modules are available")
    end
  end
  
  def test_cli_with_only_option
    in_temp_dir do | d |
      cli("#{BIN_P} --only syntheyes flm.stabilizer")
      fs = %w(. ..  flm.stabilizer flm_syntheyes_2dt.txt )
      assert_same_set fs, Dir.entries(d)
    end
  end
  
  # TODO: This currently hangs in testing
  # def test_cli_with_trace_option
  #   FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
  #   status, o, e = cli("#{BIN_P} --trace #{TEMP_DIR}/flm.stabilizer")
  # end
  
  def test_cli_reformat
    in_temp_dir do | d |
      cli("--reformat-x 1204 --reformat-y 340 --only flamestabilizer flm.stabilizer")
      p = Tracksperanto::Import::FlameStabilizer.new(:io => File.open(d + "/flm_flame.stabilizer"))
      items = p.to_a
      assert_equal 1204, p.width, "The width of the converted setup should be that"
      assert_equal 340, p.height, "The height of the converted setup should be that"
    end
  end
  
  def test_cli_trim
    in_temp_dir do | d |
      results = cli("--slip -8000 --trim --only flamestabilizer flm.stabilizer")
      assert_not_equal 0, results[0] # status
      assert_match /There were no trackers exported/, results[-1] # STDERR
    end
  end
  
  # We use this instead of assert_equals for arrays of file names since different filesystems
  # return files in different order
  def assert_same_set(expected_enum, enum, message = "Should be the same set")
    assert_equal Set.new(expected_enum), Set.new(enum), message
  end
end
