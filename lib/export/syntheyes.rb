# Export for Syntheyes tracker UVs
class Tracksperanto::Export::SynthEyes < Tracksperanto::Export::Base
  
  # Should return the suffix and extension of this export file (like "_flame.stabilizer")
  def self.desc_and_extension
    "syntheyes_2dt.txt"
  end
  
  def self.human_name
    "Syntheyes 2D tracker .txt file"
  end
  
  def start_export( img_width, img_height)
    @width, @height = img_width, img_height
  end
  
  def start_tracker_segment(tracker_name)
    @tracker_name = tracker_name
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    values = [@tracker_name, frame] + syntheyes_coords(abs_float_x, abs_float_y, @width, @height)
    @io.puts("%s %d %.6f %.6f 30" % values)
  end
  
  private
    
    # Syntheyes wants very special coordinates, Y down X right,
    # 0 is center and values are UV float -1 to 1, doubled
    def syntheyes_coords(abs_x, abs_y, w, h)
      x = (abs_x / w.to_f) - 0.5
      y = (abs_y / h.to_f) - 0.5
      # .2 to -.3, y is reversed and coords are double
      [x * 2, y * -2]
    end
end
