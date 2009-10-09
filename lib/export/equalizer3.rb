require 'tempfile'

# Export for 3DE v3 point files
class Tracksperanto::Export::Equalizer3 < Tracksperanto::Export::Base
  
  HEADER = '// 3DE Multiple Tracking Curves Export 2048 x 778 * 275 frames'
  
  # Should return the suffix and extension of this export file (like "_flame.stabilizer")
  def self.desc_and_extension
    "3de_v3.txt"
  end
  
  def self.human_name
    "3DE v3 point export .txt file"
  end
  
  def start_export( img_width, img_height)
    @w, @h = img_width, img_height
    # 3DE needs to know the number of keyframes in advance
    @internal_io, @highest_keyframe = Tempfile.new("Tracksperanto_3de"), 0
  end
  
  def start_tracker_segment(tracker_name)
    @internal_io.puts(tracker_name)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    off_by_one = frame + 1
    @internal_io.puts("\t%d\t%.3f\t%.3f" % [off_by_one, abs_float_x, abs_float_y])
    @highest_keyframe = off_by_one if (@highest_keyframe < off_by_one)
  end
  
  def end_export
    preamble = HEADER.gsub(/2048/, @w.to_s).gsub(/778/, @h.to_s).gsub(/275/, @highest_keyframe.to_s)
    @io.puts(preamble)
    @internal_io.rewind
    @io.puts(@internal_io.read)
    @internal_io = nil # Discard for GC
    @io.puts("")
  end
  
end
