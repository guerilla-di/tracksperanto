# Internal representation of a keyframe, that carries info on the frame location in the clip, x y and residual
# Frame numbers start from zero (frame 0 is first frame of the clip).
# Tracksperanto uses Shake coordinates as base. Image is Y-positive, X-positive, absolute
# pixel values up and right (zero is in the lower left corner). Some apps use a different
# coordinate system so translation will take place on import or on export, respectively.
# We also use residual and not correlation (residual is how far the tracker strolls away,
# correlation is how sure the tracker is about what it's doing). Residual is the inverse of
# correlation (with total correlation of one the residual excursion becomes zero).
class Tracksperanto::Keyframe
  include Tracksperanto::Casts
  include Tracksperanto::BlockInit
  
  # Absolute integer frame where this keyframe is placed, 0 based
  attr_accessor :frame
  
  # Absolute float X value of the point, zero is lower left
  attr_accessor :abs_x
  
  # Absolute float Y value of the point, zero is lower left
  attr_accessor :abs_y
  
  # Absolute float residual (0 is "spot on")
  attr_accessor :residual
  
  cast_to_float :abs_x, :abs_y, :residual
  cast_to_int :frame
  
  def inspect
    [frame, abs_x, abs_y].inspect
  end
end