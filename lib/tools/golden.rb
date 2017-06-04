# This tool marks all trackers as being 100% accurate
class Tracksperanto::Tool::Golden < Tracksperanto::Tool::Base
  
  def self.action_description
    "Reset residual of all the trackers to zero"
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame, float_x, float_y, 0.0)
  end
  
end
