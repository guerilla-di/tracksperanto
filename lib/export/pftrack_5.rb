# Export for PFTrack .2dt files for version 5
class Tracksperanto::Export::PFTrack5 < Tracksperanto::Export::PFTrack4
    
    def self.desc_and_extension
      "pftrack_v5.2dt"
    end
    
    def self.human_name
      "PFTrack v5 .2dt file"
    end
    
    def end_tracker_segment
      block = [ "\n",
        @tracker_name.inspect, # "autoquotes"
        "Primary".inspect,
        @prev_tracker.length,
        @prev_tracker.join("\n") ]
      @io.puts block.join("\n")
    end
end