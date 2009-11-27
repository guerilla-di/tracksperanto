# Implements the zip_curve_tuples method
module Tracksperanto::ZipTuples
  # Zip arrays of "value at" tuples into an array of "values at" tuples. 
  # The first value of each tuple will be the frame number
  # and keyframes which are not present in all arrays will be discarded. For example:
  #
  #    zip_curve_tuples( [[0, 12], [1, 23]], [[1, 12]]) #=> [[1, 23, 12]]
  #
  # We make use of the fact that setting an offset index in an array fills it with nils up to
  # the index inserted
  def zip_curve_tuples(*curves)
    tuples = curves.inject([]) do | tuples, curve_of_at_and_value |
      curve_of_at_and_value.each do | frame, value |
       tuples[frame] = tuples[frame] ? (tuples[frame] << value) : [frame, value]
      end
      tuples
    end
    
    tuples.reject{|e| e.nil? || (e.length < (curves.length + 1)) }
  end
end