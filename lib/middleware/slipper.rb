class Tracksperanto::Middleware::Slipper < Tracksperanto::Middleware::Base
  DEFAULT_SLIP = 0
  attr_accessor :slip
  
  def slip
    @slip.to_i || DEFAULT_SLIP
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame + slip, float_x, float_y, float_residual)
  end
end