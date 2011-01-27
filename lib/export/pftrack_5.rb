# Export for PFTrack .2dt files for version 5
class Tracksperanto::Export::PFTrack5 < Tracksperanto::Export::PFTrack4
    
    def self.desc_and_extension
      "pftrack_v5.2dt"
    end
    
    def self.human_name
      "PFTrack v5 .2dt file"
    end
    
    def end_tracker_segment
      @io.write("\r\n\r\n")
      @io.write(@tracker_name.inspect) # autoquotes
      @io.write("\r\n")
      @io.write("Primary".inspect) # For primary/secondary cam in stereo pair
      @io.write("\r\n")
      @io.write(@frame_count)
      @io.write("\r\n")
      
      @tracker_io.rewind
      @io.write(@tracker_io.read) until @tracker_io.eof?
      @tracker_io.close!
    end
end