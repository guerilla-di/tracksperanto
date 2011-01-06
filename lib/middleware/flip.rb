# Flips the comp being exported horizontally
class Tracksperanto::Middleware::Flip < Tracksperanto::Middleware::Base
  
  attr_accessor :enabled
  
  def start_export(w, h)
    @w, @h = w, h
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    x = @enabled ? (@w - float_x) : float_x
    super(frame, x, float_y, float_residual)
  end
end