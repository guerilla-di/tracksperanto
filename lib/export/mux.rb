# Multiplexor. Accepts a number of exporters and replays 
# the calls to all of them in succession.
class Tracksperanto::Export::Mux
  attr_accessor :outputs
  
  def initialize(*outputs)
    @outputs = outputs.flatten
  end
  
  # Called on export start
  def start_export( img_width, img_height)
    @outputs.each do | output |
      output.start_export( img_width, img_height)
    end
  end

  # Called on tracker start, one for each tracker
  def start_tracker_segment(tracker_name)
    @outputs.each do | output |
      output.start_tracker_segment(tracker_name)
    end
  end
  
  def end_tracker_segment
    @outputs.each do | output |
      output.end_tracker_segment
    end
  end
  
  # Called for each tracker keyframe
  def export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
    @outputs.each do | output |
      output.export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
    end
  end
  
  def end_export
    @outputs.each{|o| o.end_export }
  end
end