require File.expand_path(File.dirname(__FILE__)) + '/helper'

class TestZipTuples < Test::Unit::TestCase
  include Tracksperanto::ZipTuples
  
  def test_zip_with_empty
    assert_equal [], zip_curve_tuples([])
  end
  
  def test_zip_with_standard_dataset
    assert_equal [[1, 123, 234]], zip_curve_tuples([[1, 123]], [[1, 234]])
  end

  def test_zip_with_missing_step
    assert_equal [[1, 123, 234]], zip_curve_tuples([[1, 123], [2, 456]], [[1, 234]])
  end

  def test_zip_with_two_curves
    curve_a = [[1, 123], [2, 345]]
    curve_b = [[1, 23.4], [2, 14.5]]
    result = [[1, 123, 23.4], [2, 345, 14.5]]
    assert_equal result, zip_curve_tuples(curve_a, curve_b)
  end
  
  def test_zip_with_negative_frame_indices
    curve_a = [[-100, 123], [24, 345]]
    curve_b = [[-100, 23.4], [24, 14.5]]
    result = [[-100, 123, 23.4], [24, 345, 14.5]]
    assert_equal result, zip_curve_tuples(curve_a, curve_b)
  end
end
