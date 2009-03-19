class Tracksperanto::Middleware::Slipper
  DEFAULT_SLIP = 0
  attr_accessor :exporter, :slip
  
  def slip
    @slip.to_i || DEFAULT_SLIP
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    exporter.export_point(frame + slip, float_x, float_y, float_residual)
  end
end