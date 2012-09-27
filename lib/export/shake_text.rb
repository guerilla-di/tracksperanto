# -*- encoding : utf-8 -*-
# Export for Shake .txt tracker blobs
class Tracksperanto::Export::ShakeText < Tracksperanto::Export::Base
  PREAMBLE = "TrackName %s\n   Frame             X             Y   Correlation\n"
  POSTAMBLE = "\n"
  TEMPLATE = "   %.2f   %.3f   %.3f   %.3f"
  
  def self.desc_and_extension
    "shake_trackers.txt"
  end
  
  def self.human_name
    "Shake trackers in a .txt file"
  end
  
  def start_tracker_segment(tracker_name)
    @io.puts PREAMBLE % tracker_name
  end
  
  def end_tracker_segment
    @io.puts POSTAMBLE
  end
   
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    # Shake starts from frame 1, not 0
    line = TEMPLATE % [frame + 1, abs_float_x, abs_float_y, 1 - float_residual]
    @io.puts line
  end
end
