# Export for 3DE v3 point files
class Tracksperanto::Export::Equalizer3 < Tracksperanto::Export::Base
  
  HEADER = '// 3DE Multiple Tracking Curves Export %d x %d * %d frames'
  
  def self.desc_and_extension
    "3de_v3.txt"
  end
  
  def self.human_name
    "3DE v3 point export .txt file"
  end
  
  def start_export( img_width, img_height)
    @w, @h = img_width, img_height
    # 3DE needs to know the number of keyframes in advance
    @buffer = Tempfile.new("ts3dex")
    @highest_keyframe = 0
  end
  
  def start_tracker_segment(tracker_name)
    @buffer.puts(tracker_name)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    off_by_one = frame + 1
    @buffer.puts("\t%d\t%.3f\t%.3f" % [off_by_one, abs_float_x, abs_float_y])
    @highest_keyframe = off_by_one if (@highest_keyframe < off_by_one)
  end
  
  def end_export
    @buffer.rewind
    @io.puts(HEADER % [@w, @h, @highest_keyframe])
    @io.puts(@buffer.read) until @buffer.eof?
    @buffer.close!
    @io.puts("") # Newline at end
  end
end
