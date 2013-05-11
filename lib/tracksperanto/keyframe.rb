# -*- encoding : utf-8 -*-
# Internal representation of a keyframe, that carries info on the frame location in the clip, x y and residual.
#
# Franme numbers are zero-based (frame 0 is first frame of the clip).
# X-coordinate (abs_x) is absolute pixels from lower left corner of the comp to the right
# Y-coordinate (abs_y) is absolute pixels from lower left corner of the comp up
# Residual is how far in pixels the tracker strolls away, and is the inverse of
# correlation (with total correlation of one the residual excursion becomes zero).
class Tracksperanto::Keyframe
  include Tracksperanto::Casts, Tracksperanto::BlockInit, Comparable
  
  # Integer frame where this keyframe is placed, 0-based
  attr_accessor :frame
  
  # Float X value of the point, zero is lower left
  attr_accessor :abs_x
  
  # Float Y value of the point, zero is lower left
  attr_accessor :abs_y
  
  # Float residual (0 is "spot on")
  attr_accessor :residual
  
  cast_to_float :abs_x, :abs_y, :residual
  cast_to_int :frame
  
  def inspect
    '#< %.1fx%.1f @%d ~%.2f) >' %  [abs_x, abs_y, frame, residual]
  end
  
  def <=>(another)
    [frame, abs_x, abs_y, residual] <=> [another.frame, another.abs_x, another.abs_y, another.residual]
  end
end
