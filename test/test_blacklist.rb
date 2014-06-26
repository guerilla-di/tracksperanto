# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestBlacklist < Test::Unit::TestCase
  
  def test_non_blacklisted_formats
    %( file.txt file.2dt file.stabilizer ).each do | filename |
      Tracksperanto::Blacklist.raise_if_format_unsupported(filename)
    end
    assert true, 'No exceptions should have been raised'
  end
  
  def test_blacklisted_formats
    %w(
      file.jpg
      file.tif
      file.tiff
      file.mov
      file.r3d
      file.dpx
      file.jpg
      file.gif
      file.PNG
      file.sni
      file.ma
      file.mb
      file.pfb
      file.mmf
    ).each do | filename |
      error = assert_raise(Tracksperanto::UnsupportedFormatError, "Should fail for #{filename.inspect}") do
        Tracksperanto::Blacklist.raise_if_format_unsupported(filename)
      end
      assert_operator error.message.length, :>, 5, 'Should contain a descriptive error message'
    end
  end
end
