# Export for PFTrack .2dt files for version 2011
class Tracksperanto::Export::PFTrack2011 < Tracksperanto::Export::PFMatchit
    
    def self.desc_and_extension
      "pftrack_2011.txt"
    end
    
    def self.human_name
      "PFTrack 2011 .txt file (single camera)"
    end
    
    def export_point(frame, abs_float_x, abs_float_y, float_residual)
      @frame_count += 1
      # PFTrack 2011 wants one-based frames
      line = KEYFRAME_TEMPLATE % [frame + 1, abs_float_x, abs_float_y, float_residual / 8]
      @tracker_io.write(line)
      @tracker_io.write(linebreak)
    end
    
    private
    
    def camera_name
      "1"
    end
    
    # PFT2011 wants \n
    def linebreak
      "\n"
    end
end