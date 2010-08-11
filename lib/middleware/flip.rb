# Flips the comp being exported horizontally or vertically
class Tracksperanto::Middleware::Flip < Tracksperanto::Middleware::Base
  
  attr_accessor :flip, :flop
  
  def start_export(w, h)
    @w, @h = w, h
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    x = @flip ? (@w - float_x) : float_x
    y = @flop ? (@h - float_y) : float_y
    super(frame, x, y, float_residual)
  end
end