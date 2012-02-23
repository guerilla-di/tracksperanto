# -*- encoding : utf-8 -*-
# This middleware marks all trackers as being 100% accurate
class Tracksperanto::Middleware::Golden < Tracksperanto::Middleware::Base
  def export_point(frame, float_x, float_y, float_residual)
    super(frame, float_x, float_y, 0.0)
  end
  
end
