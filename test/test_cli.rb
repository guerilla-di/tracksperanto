require File.expand_path(File.dirname(__FILE__)) + '/helper'

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
    old_stdout, old_stderr, old_argv = $stdout, $stderr, ARGV.dup
    os, es = StringIO.new, StringIO.new
    begin
      $stdout, $stderr, verbosity = os, es, $VERBOSE
      ARGV.replace(commandline_arguments.split)
      $VERBOSE = false
      load(BIN_P)
      return [0, os.string, es.string]
    rescue SystemExit => boom # The binary uses exit(), we use that to preserve the output code
      return [boom.status, os.string, es.string]
    ensure
      $VERBOSE = verbosity
      ARGV.replace(old_argv)
      $stdout, $stderr = old_stdout, old_stderr
    end
  end
  
  def test_cli_with_no_args_produces_usage
    status, o, e = cli('')
    assert_equal -1, status
    assert_match /Also use the --help option/, e
  end
  
  def test_cli_with_nonexisting_file
    status, o, e = cli(TEMP_DIR + "/nonexisting.file")
    assert_equal -1, status
    assert_equal "Input file #{TEMP_DIR + "/nonexisting.file"} does not exist\n", e
  end
    
  def test_basic_cli
    status, o, e = cli(TEMP_DIR + "/flm.stabilizer")
    assert_equal 0, status, "Should exit with a normal status"
    fs = %w(. .. 
      flm.stabilizer flm_3de_v3.txt flm_3de_v4.txt flm_boujou_text.txt flm_flame.stabilizer 
      flm_matchmover.rz2 flm_mayalive.txt flm_nuke.nk flm_pftrack_v4.2dt
      flm_pftrack_v5.2dt flm_shake_trackers.txt flm_syntheyes_2dt.txt
    )
    
    assert_equal fs, Dir.entries(TEMP_DIR)
  end
  
  def test_cli_with_only_option
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
    cli("#{BIN_P} --only syntheyes #{TEMP_DIR}/flm.stabilizer")
    fs = %w(. ..  flm.stabilizer flm_syntheyes_2dt.txt )
    assert_equal fs, Dir.entries(TEMP_DIR)
  end
  
  def test_cli_reformat
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
    cli("--reformat-x 1204 --reformat-y 340 --only flamestabilizer #{TEMP_DIR}/flm.stabilizer")
    
    p = Tracksperanto::Import::FlameStabilizer.new
    f = p.parse(File.open(TEMP_DIR + "/flm_flame.stabilizer"))
    assert_equal 1204, p.width, "The width of the converted setup should be that"
    assert_equal 340, p.height, "The height of the converted setup should be that"
  end
end