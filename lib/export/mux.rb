# Multiplexor. Does not inherit Base so that it does not get used as a translator
class Tracksperanto::Export::Mux
  attr_accessor :outputs
  
  def initialize(*outputs)
    @outputs = outputs
  end
  
  # Called on export start
  def start_export(export_name, img_width, img_height)
    @outputs.each do | output |
      output.start_export(export_name, img_width, img_height)
    end
  end

  # Called on tracker start, one for each tracker
  def start_tracker_segment(tracker_name)
    @outputs.each do | output |
      output.start_tracker_segment(tracker_name)
    end
  end

  # Called for each tracker keyframe
  def export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
    @outputs.each do | output |
      output.export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
    end
  end
end