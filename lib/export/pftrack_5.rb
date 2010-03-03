# Export for PFTrack .2dt files for version 5
class Tracksperanto::Export::PFTrack5 < Tracksperanto::Export::PFTrack4
    
    def self.desc_and_extension
      "pftrack_v5.2dt"
    end
    
    def self.human_name
      "PFTrack v5 .2dt file"
    end
    
    def end_tracker_segment
      @io.write("\n\n")
      @io.puts(@tracker_name.inspect) # autoquotes
      @io.puts("Primary".inspect) # For primary/secondary cam in stereo pair
      @io.puts(@frame_count)
      
      @tracker_io.rewind
      @io.write(@tracker_io.read) until @tracker_io.eof?
      @tracker_io.close!
    end
end