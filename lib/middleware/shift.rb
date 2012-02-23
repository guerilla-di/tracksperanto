# -*- encoding : utf-8 -*-
# This middleware moves the keyframs by a preset number of pixels
class Tracksperanto::Middleware::Shift < Tracksperanto::Middleware::Base
  attr_accessor :x_shift, :y_shift
  cast_to_float :x_shift, :y_shift
  
  def self.action_description
    "Move all the trackers by a specified number of pixels"
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame, float_x + @x_shift.to_f, float_y + @y_shift.to_f, float_residual)
  end
  
end
