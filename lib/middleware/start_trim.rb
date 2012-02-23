# -*- encoding : utf-8 -*-
# This middleware removes all keyframes before frame 0, and skips trackers entirely if they are all before frame 0
class Tracksperanto::Middleware::StartTrim < Tracksperanto::Middleware::Base
  
  def start_export( img_width, img_height)
    @exporter = Tracksperanto::Middleware::LengthCutoff.new(@exporter, :min_length => 1) # Ensure at least one keyframe
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    return super unless frame < 0
  end
end
