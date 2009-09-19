# This middleware moves the keyframs by a preset number of pixels
class Tracksperanto::Middleware::Shift < Tracksperanto::Middleware::Base
  attr_accessor :x_shift, :y_shift
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame, float_x + (@x_shift || 0), float_y + (@y_shift || 0), float_residual)
  end
  
end