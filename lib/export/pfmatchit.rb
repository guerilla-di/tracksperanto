# -*- encoding : utf-8 -*-
# Export for PFMatchit
class Tracksperanto::Export::PFMatchit < Tracksperanto::Export::Base
  
  include Tracksperanto::PFCoords
  
  KEYFRAME_TEMPLATE = "%s %.3f %.3f %.3f"
  
  def self.desc_and_extension
    "pftrack_2011_pfmatchit.txt"
  end
  
  def self.human_name
    "PFTrack2011/PFMatchit .txt file (single camera)"
  end
  
  def start_export(w, h)
    @width = w
    @height = h
  end
  
  def start_tracker_segment(tracker_name)
    # Setup for the next tracker
    @frame_count = 0
    @tracker_name = tracker_name
    @tracker_io = Tracksperanto::BufferIO.new
  end
  
  # TODO: currently exports to one camera
  def end_tracker_segment
    2.times { @io.write(linebreak) }
    @io.write(@tracker_name.inspect) # autoquotes
    @io.write linebreak
    @io.write camera_name # For primary/secondary cam in stereo pair
    @io.write linebreak
    @io.write @frame_count
    @io.write linebreak
    
    @tracker_io.rewind
    @io.write(@tracker_io.read) until @tracker_io.eof?
    @tracker_io.close!
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    @frame_count += 1
    line = KEYFRAME_TEMPLATE % [frame_number(frame), to_pfcoord(abs_float_x), to_pfcoord(abs_float_y), float_residual / 8]
    @tracker_io.write(line)
    @tracker_io.write(linebreak)
  end
  
  private
  
  def frame_number(tracksperanto_frame)
    tracksperanto_frame + 1
  end
  
  def linebreak
    "\n"
  end
  
  def camera_name
    "1"
  end
end
