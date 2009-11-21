# Export for Syntheyes tracker UVs
class Tracksperanto::Export::SynthEyes < Tracksperanto::Export::Base
  include Tracksperanto::UVCoordinates
  
  def self.desc_and_extension
    "syntheyes_2dt.txt"
  end
  
  def self.human_name
    "Syntheyes 2D tracker paths file"
  end
  
  def start_export( img_width, img_height)
    @width, @height = img_width, img_height
  end
  
  def start_tracker_segment(tracker_name)
    @tracker_name = tracker_name
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    values = [@tracker_name, frame] + absolute_to_uv(abs_float_x, abs_float_y, @width, @height)
    @io.puts("%s %d %.6f %.6f 30" % values)
  end
end
