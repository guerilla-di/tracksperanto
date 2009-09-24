# Export for 3DE point files
class Tracksperanto::Export::Equalizer < Tracksperanto::Export::Base
  
  # Should return the suffix and extension of this export file (like "_flame.stabilizer")
  def self.desc_and_extension
    "3de.txt"
  end
  
  def self.human_name
    "3DE point export .txt file"
  end
  
  def start_export( img_width, img_height)
    # 3DE needs to know the number of points in advance,
    # so we will just buffer to a StringIO
    @internal_io, @num_of_trackers = StringIO.new, 0
  end
  
  def start_tracker_segment(tracker_name)
    @internal_io.puts(tracker_name)
    @num_of_trackers += 1
    @tracker_buffer, @num_of_kfs = StringIO.new, 0
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    @tracker_buffer.puts("%d %.15f %.15f" % [frame + 1, abs_float_x, abs_float_y])
    @num_of_kfs += 1
  end
  
  def end_tracker_segment
    @internal_io.puts("0") # Color of the point, 0 is red
    @internal_io.puts(@num_of_kfs)
    @internal_io.puts(@tracker_buffer.string)
  end
  
  def end_export
    @io.puts(@num_of_trackers)
    @io.puts(@internal_io.string)
  end
  
end
