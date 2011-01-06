# Flips the comp being exported vertically
class Tracksperanto::Middleware::Flop < Tracksperanto::Middleware::Base
  
  attr_accessor :enabled
  
  def start_export(w, h)
    @w, @h = w, h
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    y = @enabled ? (@h - float_y) : float_y
    super(frame, float_x, y, float_residual)
  end
end