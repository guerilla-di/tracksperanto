require File.dirname(__FILE__) + '/helper'

class CliTest < Test::Unit::TestCase
  TEMP_DIR = File.expand_path(File.dirname(__FILE__) + "/tmp")
  BIN_P = File.expand_path(File.dirname(__FILE__) + "/../bin/tracksperanto")
  
  def setup
    @old_dir = Dir.pwd
    Dir.mkdir(TEMP_DIR)
    Dir.chdir(TEMP_DIR)
  end
  
  def teardown
    Dir.chdir(@old_dir)
    FileUtils.rm_rf(TEMP_DIR)
  end
  
  def cli(cmd)
    # Spin up a fork and do system() from there. This means that we can suppress the output
    # coming from the cli process, but capture the exit code.
    cpid = fork do
      STDOUT.reopen("tout")
      STDERR.reopen("tout")
      state = system(cmd)
      File.unlink("tout")
      exit(0) if state
      exit(-1)
    end
    Process.waitpid(cpid)
  end
  
  def test_basic_cli
    FileUtils.cp(File.dirname(__FILE__) + "/import/samples/flame_stabilizer/fromCombustion_fromMidClip_wSnap.stabilizer", TEMP_DIR + "/flm.stabilizer")
    cli("#{BIN_P} #{TEMP_DIR}/flm.stabilizer")
    fs = %w(. .. 
      flm.stabilizer flm_3de_v3.txt flm_3de_v4.txt flm_flame.stabilizer 
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
    cli("#{BIN_P} --reformat-x 1204 --reformat-y 340 --only flamestabilizer #{TEMP_DIR}/flm.stabilizer")
    
    p = Tracksperanto::Import::FlameStabilizer.new
    f = p.parse(File.open(TEMP_DIR + "/flm_flame.stabilizer"))
    assert_equal 1204, p.width, "The width of the converted setup should be that"
    assert_equal 340, p.height, "The height of the converted setup should be that"
  end
end