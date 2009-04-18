class Tracksperanto::Export::Pftrack < Tracksperanto::Export::Base
    
    # Should return the suffix and extension of this export file (like "_flame.stabilizer")
    def self.desc_and_extension
      "pftrack.2dt"
    end
    
    def start_tracker_segment(tracker_name)
      # If there was a previous tracker, write it out
      # - now we know how many keyframes it has
      if @prev_tracker && @prev_tracker.any?
        block = [
          "\n",
          @tracker_name.inspect, # "autoquotes"
          @prev_tracker.length,
          @prev_tracker.join("\n")
        ]
        @io.puts block.join("\n")
      end
      
      # Setup for the next tracker
      @prev_tracker = []
      @tracker_name = tracker_name
    end
    
    def export_point(frame, abs_float_x, abs_float_y, float_residual)
      line = "%s %.3f %.3f %.3f" % [frame, abs_float_x, abs_float_y, float_residual]
      @prev_tracker << line
    end
end