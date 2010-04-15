# Export for 2d3d boujou
class Tracksperanto::Export::Boujou < Tracksperanto::Export::Base
  
  def self.desc_and_extension
    "boujou_text.txt"
  end
  
  def self.human_name
    "boujou feature tracks"
  end
  
  DATETIME_FORMAT = '%a %b %d %H:%M:%S %Y'
  PREAMBLE = "#boujou 2d tracks export: text\n# boujou version: 4.1.0 28444\n" + 
    "#Creation date : %s\n# track_id    view      x    y"
  
  TEMPLATE = "%s  %d  %.3f  %.3f"
  
  def start_export( img_width, img_height)
    @height = img_height
    @io.puts(PREAMBLE % Time.now.strftime(DATETIME_FORMAT))
  end
  
  def start_tracker_segment(tracker_name)
    @tracker_name = tracker_name
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    height_inv = @height - abs_float_y
    @io.write(TEMPLATE % [@tracker_name, frame + 1, abs_float_x, height_inv])
  end
end