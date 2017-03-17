# -*- encoding : utf-8 -*-
# Reverses keyframes of all contained trackers.
class Tracksperanto::Tool::ReverseKeyframes < Tracksperanto::Tool::Base
  
  def self.action_description
    "Reverse the tracker keyframes in time. Assumes the timing starts at frame 1."
  end
  
  def start_export(width, height)
    @width, @height = width, height
    @maximum_frame_numer_seen = 1
    @minimum_frame_number_seen = 1
    @buf = Obuf.new
  end
    
  def start_tracker_segment(tracker_name)
    @current = Tracksperanto::Tracker.new(:name => tracker_name)
  end
  
  def end_tracker_segment
    @buf.push(@current)
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    @minimum_frame_number_seen = frame if frame < @minimum_frame_number_seen
    @maximum_frame_numer_seen = frame if frame > @maximum_frame_numer_seen
    @current.keyframe!(:frame => frame, :abs_x => float_x, :abs_y => float_y, :residual => float_residual)
  end
  
  def end_export
    @exporter.start_export(@width, @height)
    @buf.each do | tracker |
      @exporter.start_tracker_segment(tracker.name)
      tracker.reverse_each do | kf |
        @exporter.export_point(
          reverse_frame(@minimum_frame_number_seen, kf.frame, @maximum_frame_numer_seen),
          kf.abs_x, kf.abs_y, kf.residual)
      end
      @exporter.end_tracker_segment
    end
    @exporter.end_export
    @buf.clear
  end
  
  def reverse_frame(min_f, frame_number, max_f)
    delta = max_f - min_f
    t = (frame_number - min_f).to_f / (max_f - min_f).to_f
    inv_t = 1 - t
    (min_f.to_f + (inv_t * delta)).round
  end
end
