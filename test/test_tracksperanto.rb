require File.dirname(__FILE__) + '/helper'

class TracksperantoTest < Test::Unit::TestCase
  def test_middlewares
    m = Tracksperanto.middlewares
    m.each do | middleware_module |
      assert_kind_of Module, middleware_module
    end
  end

  def test_exporters
    m = Tracksperanto.exporters
    m.each do | x |
      assert_kind_of Class, x
    end
  end
  
  def test_importers
    m = Tracksperanto.importers
    m.each do | x |
      assert_kind_of Class, x
    end
  end
  
  def test_middleware_names
    m = Tracksperanto.middleware_names
    assert m.include?("Golden")
  end
  
  def test_importer_names
    m = Tracksperanto.importer_names
    assert m.include?("FlameStabilizer")
  end
  
  def test_exporter_names
    m = Tracksperanto.exporter_names
    assert m.include?("PFTrack5")
  end
  
  def test_get_importer
    i1 = Tracksperanto.get_importer("syntheyes")
    assert_equal i1, Tracksperanto::Import::Syntheyes
  end
  
  def test_get_importer_multicase
    i1 = Tracksperanto.get_importer("ShakeScript")
    assert_equal i1, Tracksperanto::Import::ShakeScript
  end

  def test_get_exporter
    i1 = Tracksperanto.get_exporter("syntheyes")
    assert_equal i1, Tracksperanto::Export::SynthEyes
    
    i1 = Tracksperanto.get_exporter("SynThEyes")
    assert_equal i1, Tracksperanto::Export::SynthEyes
    
    i1 = Tracksperanto.get_exporter("SynthEyes")
    assert_equal i1, Tracksperanto::Export::SynthEyes
  end
  
  def test_get_unknown_exporter_should_raise
    assert_raise(NameError) { Tracksperanto.get_exporter("foo") }
  end

end