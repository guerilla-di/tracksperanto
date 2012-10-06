# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TracksperantoTest < Test::Unit::TestCase
  def test_tools
    m = Tracksperanto.tools
    m.each do | tool_module |
      assert_kind_of Module, tool_module
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
  
  def test_importers_array_sorted_by_description
     m = Tracksperanto.importers.map{|e| e.human_name }
     assert_equal m.sort, m
   end
  
  def test_exporters_array_sorted_by_description
    m = Tracksperanto.exporters.map{|e| e.human_name }
    assert_equal m.sort, m
  end
  
  def test_tool_names
    m = Tracksperanto.tool_names
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
  
  def test_get_tool
    i1 = Tracksperanto.get_tool("lERP")
    assert_equal i1, Tracksperanto::Tool::Lerp
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
    assert_raise(Tracksperanto::UnknownExporterError) { Tracksperanto.get_exporter("foo") }
  end
  
  def test_get_unknown_importer_should_raise
    assert_raise(Tracksperanto::UnknownImporterError) { Tracksperanto.get_importer("foo") }
  end
  
  def test_get_unknown_tool_should_raise
    assert_raise(Tracksperanto::UnknownToolError) { Tracksperanto.get_tool("foo") }
  end
  
end
