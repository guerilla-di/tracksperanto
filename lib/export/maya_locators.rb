# -*- encoding : utf-8 -*-
# Export each tracker as a moving Maya locator
class Tracksperanto::Export::MayaLocators < Tracksperanto::Export::Base
  PREAMBLE = 'polyPlane -name "TracksperantoImagePlane" -width %0.5f -height %0.5f;'
  LOCATOR_PREAMBLE = 'spaceLocator -name "%s" -p 0 0 0;'
  MOVE_TIMEBAR = 'currentTime %d;'
  KEYFRAME_TEMPLATE = 'setKeyframe -value %0.5f "%s.%s";';
  
  # Scaling factor multiplier
  attr_accessor :multiplier
  
  def self.desc_and_extension
    "mayaLocators.mel"
  end
  
  def self.human_name
    "Maya .mel script that generates locators"
  end
  
  def start_export(w, h)
    # Pixel sizes are HUGE for maya. What we do is we assume that the width is 1,
    # and scale the height to that
    multiplier = self.multiplier || 10.0
    
    @factor = (1 / w.to_f) * multiplier
    
    @io.puts(PREAMBLE % [multiplier, h * @factor])
    @io.puts('rotate -r -os 90;') # Position it in the XY plane
    @io.puts('move -r %0.5f %0.5f 0;' % [multiplier / 2.0, h * @factor / 2.0])
    @group_members = ["TracksperantoImagePlane"]
  end
  
  # We accumulate a tracker and on end dump it out in one piece
  def start_tracker_segment(tracker_name)
    @locator_name = tracker_name
    @io.puts(LOCATOR_PREAMBLE % @locator_name)
    @group_members.push(tracker_name)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    @io.puts(MOVE_TIMEBAR % (frame + 1))
    @io.puts(KEYFRAME_TEMPLATE % [abs_float_x * @factor, @locator_name, "tx"])
    @io.puts(KEYFRAME_TEMPLATE % [abs_float_y * @factor, @locator_name, "ty"])
  end
  
  def end_export
    @io.puts(MOVE_TIMEBAR % 1)
    # Group all the stuff
    @io.puts('select -r %s;' % @group_members.join(' '))
    @io.puts('group -name TracksperantoGroup; xform -os -piv 0 0 0;')
  end
  
end
