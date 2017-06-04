# Export for PFTrack .2dt files
class Tracksperanto::Export::PFTrack4 < Tracksperanto::Export::Base
    
    include Tracksperanto::PFCoords
    
    KEYFRAME_TEMPLATE = "%s %.3f %.3f %.3f"
    
    # PFtrack wants cross-platform linebreaks
    LINEBREAK = "\r\n"
    
    def self.desc_and_extension
      "pftrack_v4.2dt"
    end
    
    def self.human_name
      "PFTrack v4 .2dt file"
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
    
    def end_tracker_segment
      2.times { @io.write(LINEBREAK) }
      @io.write(@tracker_name.inspect) # autoquotes
      @io.write(LINEBREAK)
      @io.write(@frame_count)
      @io.write(LINEBREAK)
      
      @tracker_io.rewind
      @io.write(@tracker_io.read) until @tracker_io.eof?
      @tracker_io.close!
    end
    
    def export_point(frame, abs_float_x, abs_float_y, float_residual)
      @frame_count += 1
      line = KEYFRAME_TEMPLATE % [frame, to_pfcoord(abs_float_x), to_pfcoord(abs_float_y), float_residual / 8]
      @tracker_io.write(line)
      @tracker_io.write(LINEBREAK)
    end
end
