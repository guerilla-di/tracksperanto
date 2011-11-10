# Exports setups with tracker naming that works with the Action bilinears
class Tracksperanto::Export::FlameStabilizerCornerpin < Tracksperanto::Export::FlameStabilizer
  
  CORNERPIN_NAMING = %w( none top_left top_right bottom_left bottom_right )
  
  def self.desc_and_extension
    "flame_cornerpin.stabilizer"
  end
  
  def self.human_name
    "Flame/Smoke 2D Stabilizer setup for bilinear corner pins"
  end
  
  def prefix(tracker_channel)
    tracker_name = CORNERPIN_NAMING[@counter] || ("tracker%d" % @counter)
    [tracker_name, tracker_channel].join("/")
  end
  
  def start_tracker_segment(tracker_name)
    if (@counter == 4)
      @skip = true
    else
      super
    end 
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    return if @skip
    super
  end
  
  def end_tracker_segment
    return if @skip
    super
  end
end
