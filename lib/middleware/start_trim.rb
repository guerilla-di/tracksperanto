# -*- encoding : utf-8 -*-
# This middleware removes all keyframes before frame 0, and skips trackers entirely if they are all before frame 0
class Tracksperanto::Middleware::StartTrim < Tracksperanto::Middleware::Base
  attr_accessor :enabled
  
  def start_export( img_width, img_height)
    if @enabled
      @exporter = Tracksperanto::Middleware::LengthCutoff.new(@exporter, :min_length => 1) # Ensure at least one keyframe
    end
    
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    return super unless (@enabled && frame < 0)
  end
end
