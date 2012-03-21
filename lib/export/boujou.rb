# -*- encoding : utf-8 -*-
# Export for 2d3d boujou
class Tracksperanto::Export::Boujou < Tracksperanto::Export::Base
  
  def self.desc_and_extension
    "boujou_text.txt"
  end
  
  def self.human_name
    "boujou feature tracks"
  end
  
  DATETIME_FORMAT = '%a %b %d %H:%M:%S %Y'
  PREAMBLE = %[# boujou 2d tracks export: text
# boujou version: 4.1.0 28444 
# Creation date : %s
# 
# track_id      view      x      y]
  POINT_T = "%s  %d  %.3f  %.3f"
  
  def start_export( img_width, img_height)
    @height = img_height
    @io.puts(PREAMBLE % Time.now.strftime(DATETIME_FORMAT))
  end
  
  def start_tracker_segment(tracker_name)
    @tracker_name = tracker_name
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    height_inv = @height - abs_float_y
    # Frames in Boujou are likely to start from 0
    @io.puts(POINT_T % [@tracker_name, frame, abs_float_x, height_inv + 1])
  end
end
