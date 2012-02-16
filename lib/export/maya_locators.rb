# -*- encoding : utf-8 -*-
# Export each tracker as a moving Maya locator
class Tracksperanto::Export::MayaLocators < Tracksperanto::Export::Base
  SCENE_PREAMBLE = [
    '//Maya ASCII 2011 scene',
    '//Name: TracksperantoLocators.ma',
    '//Codeset: UTF-8',
    'requires maya "1.0";'
  ].join("\n")
  
  PREAMBLE = 'polyPlane -name "TracksperantoImagePlane" -width %0.5f -height %0.5f;'
  LOCATOR_PREAMBLE = 'spaceLocator -name "%s" -p 0 0 0;'
  KEYFRAME_TEMPLATE = 'setKeyframe -time %d -value %0.5f "%s.%s";';
  MULTIPLIER = 10.0
  
  def self.desc_and_extension
    "mayaLocators.ma"
  end
  
  def self.human_name
    "Maya ASCII scene with locators on an image plane"
  end
  
  def start_export(w, h)
    # Pixel sizes are HUGE for maya. What we do is we assume that the width is 1,
    # and scale the height to that
    @factor = (1 / w.to_f) * MULTIPLIER
    
    @io.puts(SCENE_PREAMBLE)
    @io.puts(PREAMBLE % [MULTIPLIER, h * @factor])
    @io.puts('rotate -r -os 90;') # Position it in the XY plane
    @io.puts('move -r %0.5f %0.5f 0;' % [MULTIPLIER / 2.0, h * @factor / 2.0])
    @group_members = ["TracksperantoImagePlane"]
  end
  
  def start_tracker_segment(tracker_name)
    @locator_name = tracker_name
    @io.puts(LOCATOR_PREAMBLE % @locator_name)
    @group_members.push(tracker_name)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    @io.puts(KEYFRAME_TEMPLATE % [frame + 1, abs_float_x * @factor, @locator_name, "tx"])
    @io.puts(KEYFRAME_TEMPLATE % [frame + 1, abs_float_y * @factor, @locator_name, "ty"])
  end
  
  def end_export
    # Group all the stuff
    @io.puts('select -r %s;' % @group_members.join(' '))
    @io.puts('group -name TracksperantoGroup; xform -os -piv 0 0 0;')
  end
  
end
