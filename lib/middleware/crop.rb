# Does the same as the Pad middleware but with absolute pixel values instead of fractionals
class Tracksperanto::Middleware::Crop < Tracksperanto::Middleware::Base
  attr_accessor :top, :left, :right, :bottom
  cast_to_int :top, :left, :right, :bottom
  
  def start_export(w, h)
    left_pad, right_pad, top_pad, bottom_pad = (left / w.to_f), (right / w.to_f), (top / h.to_f), (bottom / h.to_f)
    @pad = Tracksperanto::Middleware::Pad.new(@exporter, :left_pad => left_pad, :right_pad => right_pad, :top_pad => top_pad, :bottom_pad => bottom_pad)
    @pad.start_export(w, h)
  end
  
  # Redirect all method calls to @pad instead of @exporter
  %w( start_tracker_segment end_tracker_segment export_point end_export).each do | m |
    define_method(m){|*a| @pad.send(m, *a)}
  end
end