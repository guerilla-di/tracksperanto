# Does the same as the Pad tool but with absolute pixel values instead of fractionals
class Tracksperanto::Tool::Crop < Tracksperanto::Tool::Base
  
  parameter :top, :cast => :int, :desc => "Top crop amount in px"
  parameter :left, :cast => :int, :desc => "Left crop amount in px"
  parameter :right, :cast => :int, :desc => "Right crop amount in px"
  parameter :bottom, :cast => :int, :desc => "Bottom crop amount in px"
  
  def self.action_description
    "Crop or pad the image by a specified number of pixels"
  end
  
  def start_export(w, h)
    left_pad, right_pad, top_pad, bottom_pad = (left / w.to_f), (right / w.to_f), (top / h.to_f), (bottom / h.to_f)
    @pad = Tracksperanto::Tool::Pad.new(@exporter, :left_pad => left_pad, :right_pad => right_pad, :top_pad => top_pad, :bottom_pad => bottom_pad)
    @pad.start_export(w, h)
  end
  
  # Redirect all method calls to @pad instead of @exporter
  %w( start_tracker_segment end_tracker_segment export_point end_export).each do | m |
    define_method(m){|*a| @pad.send(m, *a)}
  end
end
