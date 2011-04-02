# Export for PFTrack .2dt files for version 5
class Tracksperanto::Export::PFTrack5 < Tracksperanto::Export::PFMatchit
    
    def self.desc_and_extension
      "pftrack_v5.2dt"
    end
    
    def self.human_name
      "PFTrack v5 .2dt file (single camera)"
    end
    
    private
    
    def camera_name
      "Primary".inspect
    end
    
    # PFT5 wants CRLF
    def linebreak
      "\r\n"
    end
end