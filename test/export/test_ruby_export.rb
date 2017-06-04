require File.expand_path(File.dirname(__FILE__)) + '/../helper'

class RubyExportTest < Test::Unit::TestCase
  include ParabolicTracks
  P = File.dirname(__FILE__) + "/samples/ref_Ruby.rb"
  
  def test_export_output_written
    ensure_same_output Tracksperanto::Export::Ruby, P
  end
  
  def test_exporter_meta
    assert_equal "tracksperanto_ruby.rb", Tracksperanto::Export::Ruby.desc_and_extension
    assert_equal "Bare Ruby code", Tracksperanto::Export::Ruby.human_name
  end
end
