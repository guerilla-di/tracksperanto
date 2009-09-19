# Implements the zip_curve_tuples method
module Tracksperanto::ZipTuples
  # Zip arrays of "value at" tuples into an array of "values at" tuples. 
  # The first value of each tuple will be the frame number
  # and keyframes which are not present in all arrays will be discarded. For example:
  #
  #    zip_curve_tuples( [[0, 12], [1, 23]], [[1, 12]]) #=> [[1, 23, 12]]
  #
  def zip_curve_tuples(*curves)
    tuples = []
    curves.each do | curve |
      curve.each do | keyframe |
        frame, value = keyframe
        tuples[frame] ? tuples[frame].push(value) : (tuples[frame] = [frame, value])
      end
    end

    tuples.compact.reject{|e| e.length < (curves.length + 1) }
  end
end
