# Export for Nuke's CameraTracker node. Same format as Shake Text
# except that all trackers have to be called "usertrack0" to "usertrackN"
require_relative "shake_text"

class Tracksperanto::Export::NukeCameraUsertracks < Tracksperanto::Export::ShakeText
  
  def self.desc_and_extension
    "nuke_cam_trk_autotracks.txt"
  end
  
  def self.human_name
    "Nuke CameraTracker node autotracks (enable import/export in the Tracking tab)"
  end
  
  def start_export(w, h)
    super
    @counter = 0
  end
  
  NAMING = "autotrack%d" # change to "usertrack%d" if user tracks are needed
  def start_tracker_segment(tracker_name)
    super(NAMING % @counter)
    @counter += 1
  end
end
