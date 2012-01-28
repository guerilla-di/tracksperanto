# -*- encoding : utf-8 -*-
# Export each tracker as an AfterEffects script creating nulls
class Tracksperanto::Export::AE < Tracksperanto::Export::Base

  PREAMBLE = 'function convertFrameToSeconds(layerWithFootage, frameValue)
  {
  		var comp = layerWithFootage.containingComp;
  		var rate = 1.0 / comp.frameDuration;
  		// Frames in AE are 0-based by default
  		return (frameValue) / rate;
  }'

  def self.desc_and_extension
    "createNulls.jsx"
  end
  
  def self.human_name
    "AE .jsx script generating null layers"
  end
  
  def start_export(w, h)
    @io.puts(PREAMBLE)
    @io.puts("")
    @count = 0
  end
  
  def start_tracker_segment(tracker_name)
    @io.puts("")
    @io.puts('var layer%d = app.project.activeItem.layers.addNull();' % @count)
    @io.puts( 'layer%d.name = %s;' % [@count, tracker_name.inspect])
    @io.puts("")
    @io.puts('var pos = layer%d.property("Transform").property("Position");' % @count)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    @io.puts('pos.setValueAtTime(convertFrameToSeconds(layer%d, %d), [%0.5f,%0.5f]);' % [@count, frame, abs_float_x, abs_float_y])
  end
  
  def end_tracker_segment
    @count += 1
  end
  
end
