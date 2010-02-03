# This middleware removes trackers that contain less than min_length keyframes
# from the exported batch
class Tracksperanto::Middleware::LengthCutoff < Tracksperanto::Middleware::Base
  attr_accessor :min_length
  cast_to_int :min_length
  
  def start_tracker_segment(name)
    @tracker = Tracksperanto::Tracker.new(:name => name)
  end
  
  def end_tracker_segment
    return if ((min_length > 0)  && (@tracker.length < min_length))
    
    @exporter.start_tracker_segment(@tracker.name)
    @tracker.each{|kf| @exporter.export_point(kf.frame, kf.abs_x, kf.abs_y, kf.residual) }
    @exporter.end_tracker_segment
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    @tracker.keyframe! :abs_x => float_x, :abs_y => float_y, :residual => float_residual, :frame => frame
  end
  
  
end