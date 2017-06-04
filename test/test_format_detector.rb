require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestFormatDetector < Test::Unit::TestCase
  
  def test_match_unknown
    file = "/tmp/unknown.someext"
    d = Tracksperanto::FormatDetector.new(file)
    
    assert d.frozen?
    assert !d.match?
    assert !d.auto_size?
    assert_nil d.importer_klass
    assert_equal "Unknown format", d.human_importer_name
  end
  
  
  def test_match_nuke
    file = "C:\\WINDOZE_SHIT\\SUPERDUPER.NK"
    d = Tracksperanto::FormatDetector.new(file)
    assert d.frozen?
    
    assert d.match?
    assert !d.auto_size?
    assert_equal Tracksperanto::Import::NukeScript, d.importer_klass
    assert_equal Tracksperanto::Import::NukeScript.human_name, d.human_importer_name
  end
  
  def test_match_flame
    file = "/usr/discreet/project/StupidCommercial/stabilizer/uno.stabilizer"
    d = Tracksperanto::FormatDetector.new(file)
    assert d.frozen?
    
    assert d.match?
    assert d.auto_size?
    assert_equal Tracksperanto::Import::FlameStabilizer, d.importer_klass
    assert_equal "Flame .stabilizer file", d.human_importer_name
  end
  
end
