# Export for PFMatchit
class Tracksperanto::Export::PFMatchit < Tracksperanto::Export::Base
  
  # PFtrack wants cross-platform linebreaks
  LINEBREAK = "\r\n"
  KEYFRAME_TEMPLATE = "%s %.3f %.3f %.3f\r\n"
  
  def self.desc_and_extension
    "pfmatchit.2dt"
  end
  
  def self.human_name
    "PFMatchit .2dt file (single camera)"
  end
  
  def start_tracker_segment(tracker_name)
    # Setup for the next tracker
    @frame_count = 0
    @tracker_name = tracker_name
    @tracker_io = Tracksperanto::BufferIO.new
  end
  
  def end_tracker_segment
    2.times { @io.write(LINEBREAK) }
    @io.write(@tracker_name.inspect) # autoquotes
    @io.write LINEBREAK
    @io.write camera_name # For primary/secondary cam in stereo pair
    @io.write LINEBREAK
    @io.write @frame_count
    @io.write LINEBREAK
    
    @tracker_io.rewind
    @io.write(@tracker_io.read) until @tracker_io.eof?
    @tracker_io.close!
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    @frame_count += 1
    line = KEYFRAME_TEMPLATE % [frame, abs_float_x, abs_float_y, float_residual / 8]
    @tracker_io.write(line)
  end
  
  private
  
  def camera_name
    "1"
  end
end