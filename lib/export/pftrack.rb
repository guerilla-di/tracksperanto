# Export for PFTrack .2dt files
class Tracksperanto::Export::PFTrack < Tracksperanto::Export::Base
    
    KEYFRAME_TEMPLATE = "%s %.3f %.3f %.3f"
    
    def self.desc_and_extension
      "pftrack.2dt"
    end
    
    def self.human_name
      "PFTrack .2dt file"
    end
    
    def start_tracker_segment(tracker_name)
      # Setup for the next tracker
      @prev_tracker = []
      @tracker_name = tracker_name
    end
    
    def end_tracker_segment
      block = [ "\n",
        @tracker_name.inspect, # "autoquotes"
        @prev_tracker.length,
        @prev_tracker.join("\n") ]
      @io.puts block.join("\n")
    end
    
    def export_point(frame, abs_float_x, abs_float_y, float_residual)
      line = KEYFRAME_TEMPLATE % [frame, abs_float_x, abs_float_y, float_residual / 8]
      @prev_tracker << line
    end
end