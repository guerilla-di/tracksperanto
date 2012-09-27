# -*- encoding : utf-8 -*-
# Export for Nuke's CameraTracker node. Same format as Shake Text
# except that all trackers have to be called "usertrack0" to "usertrackN"
require File.dirname(__FILE__) + "/shake_text"

class Tracksperanto::Export::NukeCameraUsertracks < Tracksperanto::Export::ShakeText
  
  def self.desc_and_extension
    "nuke_cam_trk_usertracks.txt"
  end
  
  def self.human_name
    "Nuke CameraTracker node usertracks"
  end
  
  def start_export(w, h)
    super
    @counter = 0
  end
  
  def start_tracker_segment(tracker_name)
    super("usertrack%d" % @counter)
    @counter += 1
  end
end
