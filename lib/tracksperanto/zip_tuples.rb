# -*- encoding : utf-8 -*-
# Implements the zip_curve_tuples method
module Tracksperanto::ZipTuples
  # Zip arrays of "value at" tuples into an array of "values at" tuples
  # (note the plural). 
  # The first value of each tuple will be the frame number
  # and keyframes which are not present in all arrays will be discarded. For example:
  #
  #    zip_curve_tuples( [[0, 12], [1, 23]], [[1, 12]]) #=> [[1, 23, 12]]
  #
  # We make use of the fact that setting an offset index in an array fills it with nils up to
  # the index inserted
  def zip_curve_tuples(*given_curves)
    tuples = {}
    given_curves.each_with_index do | curve, curve_i |
      curve.each do | frame_value_tuple |
        frame, value = frame_value_tuple
        tuples[frame] ||= Array.new(given_curves.length)
        tuples[frame][curve_i] = value
      end
    end
    
    tuples.delete_if {|k,v| v.include?(nil) } # If any of the positions is nil
    
    tuples.keys.sort.map do | frame_in_order |
      [frame_in_order] + tuples[frame_in_order]
    end
  end
end
