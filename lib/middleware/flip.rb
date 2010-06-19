# Flips the comp being exported horizontally
class Tracksperanto::Middleware::Flip < Tracksperanto::Middleware::Base
  
  attr_accessor :enabled
  
  def export_point(frame, float_x, float_y, float_residual)
    return super unless @enabled
    super(frame, (float_x * -1), float_y, float_residual)
  end
end