# -*- encoding : utf-8 -*-
# Slips the keyframe positions by a specific integer amount of frames, positive values slip forward (later in time). Useful if you just edited some stuff onto
# the beginning if your sequence and need to extend your tracks.
class Tracksperanto::Middleware::Slipper < Tracksperanto::Middleware::Base
  attr_accessor :slip
  cast_to_int :slip
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame + @slip.to_i, float_x, float_y, float_residual)
  end
end
