# Internal representation of a keyframe
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