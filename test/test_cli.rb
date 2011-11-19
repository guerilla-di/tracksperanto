require File.expand_path(File.dirname(__FILE__)) + '/helper'
require "set"
require "cli_test"

class CliTest < Test::Unit::TestCase
  TEMP_DIR = File.expand_path(File.dirname(__FILE__) + "/tmp")
  BIN_P = File.expand_path(File.dirname(__FILE__) + "/../bin/tracksperanto")
  
  def setup
    Dir.mkdir(TEMP_DIR) unless File.exist?(TEMP_DIR)
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
  end
  
  def teardown
    FileUtils.rm_rf(TEMP_DIR)
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
    status, o, e = cli(TEMP_DIR + "/nonexisting.file")
    assert_equal 1, status
    assert_equal "Input file #{TEMP_DIR + "/nonexisting.file"} does not exist\n", e
  end
    
  def test_basic_cli
    status, o, e = cli(TEMP_DIR + "/flm.stabilizer")
    assert_equal 0, status, "Should exit with a normal status"
    fs = %w(. .. 
      flm.stabilizer flm_3de_v3.txt flm_3de_v4.txt flm_boujou_text.txt flm_flame.stabilizer 
      flm_matchmover.rz2 flm_mayalive.txt flm_nuke.nk flm_pftrack_2011_pfmatchit.txt flm_pftrack_v4.2dt
      flm_pftrack_v5.2dt flm_shake_trackers.txt flm_syntheyes_2dt.txt flm_flame_cornerpin.stabilizer
    )
    
    assert_same_set fs, Dir.entries(TEMP_DIR)
  end
  
  def test_cli_with_error_on_nonsequentials_matchmover_to_pftrack5
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/match_mover/NonSequentialMatchmoverPoints.rz2", TEMP_DIR + "/mm.rz2")
    status, o, e = cli(TEMP_DIR + "/mm.rz2 --only pftrack5")
    assert_equal "", e
    assert_equal 0, status, "Should exit with a normal status"
    
    fs = %w(. .. flm.stabilizer mm.rz2 mm_pftrack_v5.2dt )
    assert_same_set fs, Dir.entries(TEMP_DIR)
  end
  
  def test_cli_with_nonexisting_only_exporter_prints_proper_error_message
    status, o, e = cli("--only microsoftfuckingword " + TEMP_DIR + "/flm.stabilizer")
    assert_equal 2, status, "Should exit with abnormal state"
    assert e.include?("Unknown exporter \"microsoftfuckingword\"")
    assert e.include?("The following export modules are available")
  end
  
  def test_cli_with_nonexisting_importer_prints_proper_error_message
    status, o, e = cli("--from microsoftfuckingword " + TEMP_DIR + "/flm.stabilizer")
    assert_equal 2, status, "Should exit with abnormal state"
    assert e.include?("Unknown importer \"microsoftfuckingword\"")
    assert e.include?("The following import modules are available")
  end
  
  def test_cli_with_only_option
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
    cli("#{BIN_P} --only syntheyes #{TEMP_DIR}/flm.stabilizer")
    fs = %w(. ..  flm.stabilizer flm_syntheyes_2dt.txt )
    assert_same_set fs, Dir.entries(TEMP_DIR)
  end
  
  # TODO: This currently hangs in testing
  # def test_cli_with_trace_option
  #   FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
  #   status, o, e = cli("#{BIN_P} --trace #{TEMP_DIR}/flm.stabilizer")
  # end
  
  def test_cli_reformat
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
    cli("--reformat-x 1204 --reformat-y 340 --only flamestabilizer #{TEMP_DIR}/flm.stabilizer")
    
    p = Tracksperanto::Import::FlameStabilizer.new(:io => File.open(TEMP_DIR + "/flm_flame.stabilizer"))
    items = p.to_a
    assert_equal 1204, p.width, "The width of the converted setup should be that"
    assert_equal 340, p.height, "The height of the converted setup should be that"
  end
  
  def test_cli_trim
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
    results = cli("--slip -8000 --trim --only flamestabilizer #{TEMP_DIR}/flm.stabilizer")
    assert_not_equal 0, results[0] # status
    assert_match /There were no trackers exported /, results[-1] # STDERR
  end
  
  # We use this instead of assert_equals for arrays since different filesystems
  # return files in different order
  def assert_same_set(expected_enum, enum, message = "Should be the same set")
    assert_equal Set.new(expected_enum), Set.new(enum), message
  end
end