# Export for PFTrack .2dt files for version 2011
class Tracksperanto::Export::PFTrack2011 < Tracksperanto::Export::PFMatchit
    
    def self.desc_and_extension
      "pftrack_2011.txt"
    end
    
    def self.human_name
      "PFTrack 2011 .txt file (single camera)"
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