# Export for PFTrack .2dt files
class Tracksperanto::Export::PFTrack4 < Tracksperanto::Export::Base
    
    KEYFRAME_TEMPLATE = "%s %.3f %.3f %.3f"
    
    def self.desc_and_extension
      "pftrack_v4.2dt"
    end
    
    def self.human_name
      "PFTrack v4 .2dt file"
    end
    
    def start_tracker_segment(tracker_name)
      # Setup for the next tracker
      @frame_count = 0
      @tracker_name = tracker_name
      @tracker_io = Tracksperanto::BufferIO.new
    end
    
    def end_tracker_segment
      @io.write("\n\n")
      @io.puts(@tracker_name.inspect) # autoquotes
      @io.puts(@frame_count)
      
      @tracker_io.rewind
      @io.write(@tracker_io.read) until @tracker_io.eof?
      @tracker_io.close!
    end
    
    def export_point(frame, abs_float_x, abs_float_y, float_residual)
      @frame_count += 1
      line = KEYFRAME_TEMPLATE % [frame, abs_float_x, abs_float_y, float_residual / 8]
      @tracker_io.write(line)
      @tracker_io.write("\r\n")
    end
end