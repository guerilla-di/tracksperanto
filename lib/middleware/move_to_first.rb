# -*- encoding : utf-8 -*-
# Sometimes your tracked sequence has been loaded from say frame 73282381, but you want to import into an application
# that expects the trackers to start at frame 1. This middleware autoslips everything so that your trackers start at frame 1.
class Tracksperanto::Middleware::MoveToFirst < Tracksperanto::Middleware::Base
  
  def self.action_description
    "Move all the keyframes in time so that the first frame is the first animated keyframe"
  end
  
  def start_export(width, height)
    @width, @height = width, height
    @start_frames = []
    @buf = Obuf.new
    @registered = false
  end
    
  def start_tracker_segment(tracker_name)
    @current = Tracksperanto::Tracker.new(:name => tracker_name)
  end
  
  def end_tracker_segment
    @buf.push(@current)
    @registered = false
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    @current.keyframe!(:frame => frame, :abs_x => float_x, :abs_y => float_y, :residual => float_residual)
    return if @registered
    
    # Note where this tracker starts
    @start_frames.push(frame)
    @registered = true
  end
  
  def end_export
    actual_start = @start_frames.sort.shift
    
    @exporter.start_export(@width, @height)
    @buf.each do | tracker |
      @exporter.start_tracker_segment(tracker.name)
      tracker.each do | kf |
        @exporter.export_point(kf.frame - actual_start, kf.abs_x, kf.abs_y, kf.residual)
      end
      @exporter.end_tracker_segment
    end
    @exporter.end_export
    
    @buf.clear
  end
end
