# -*- encoding : utf-8 -*-
# Slips the keyframe positions by a specific integer amount of frames, positive values slip forward (later in time). Useful if you just edited some stuff onto
# the beginning if your sequence and need to extend your tracks.
class Tracksperanto::Tool::Slipper < Tracksperanto::Tool::Base
  
  parameter :slip,  :cast => :int, :desc => "Number of frames to slip related to the current frames", :default => 0
  
  def self.action_description
    "Slip all the tracker keyframes in time"
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame + @slip.to_i, float_x, float_y, float_residual)
  end
end
