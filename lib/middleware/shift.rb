# -*- encoding : utf-8 -*-
# This middleware moves the keyframs by a preset number of pixels
class Tracksperanto::Middleware::Shift < Tracksperanto::Middleware::Base
  
  parameter :x_shift,  :cast => :float, :desc => "Amount of horizontal shift (in px)", :default => 0
  parameter :y_shift,  :cast => :float, :desc => "Amount of vertical shift (in px)", :default => 0
  
  def self.action_description
    "Move all the trackers by a specified number of pixels"
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame, float_x + @x_shift.to_f, float_y + @y_shift.to_f, float_residual)
  end
  
end
