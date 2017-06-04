# This tool removes all keyframes before frame 0, and skips trackers entirely if they are all before frame 0
class Tracksperanto::Tool::StartTrim < Tracksperanto::Tool::Base
  
  def self.action_description
    "Remove all the keyframes that are on frames below 1"
  end
  
  def start_export( img_width, img_height)
    @exporter = Tracksperanto::Tool::LengthCutoff.new(@exporter, :min_length => 1) # Ensure at least one keyframe
    super
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    return super unless frame < 0
  end
end
