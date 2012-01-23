# -*- encoding : utf-8 -*-
class Tracksperanto::Export::MayaLive < Tracksperanto::Export::Base
  
  # Maya Live exports and imports tracks in "aspect units", so a point at 0,0
  # will be at -1.78,-1 in MayaLive coordinates with aspect of 1.78. Therefore
  # we offer an override for the aspect being exported
  attr_accessor :aspect
  
  def self.desc_and_extension
    "mayalive.txt"
  end
  
  def self.human_name
    "MayaLive track export"
  end
  
  def start_export( img_width, img_height)
    @aspect ||= img_width.to_f / img_height
    
    @w, @h = img_width, img_height
    
    first_line = (%w( # Size) + [@w, @h, "%.2f" % @aspect]).join("  ")
    @io.puts(first_line)
    @tracker_number = 0
  end
  
  def start_tracker_segment(tracker_name)
    @io.puts('#  Name %s' % tracker_name)
  end
  
  def end_tracker_segment
    @tracker_number += 1
  end
  
  FORMAT_LINE = "%d %d %.10f %.10f %s"
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    values = [
      @tracker_number, frame,
      aspectize_x(abs_float_x), aspectize_y(abs_float_y),
      residual_with_reset(float_residual)
    ]
    @io.puts(FORMAT_LINE % values)
  end
  
  private
    
    def aspectize_x(pix)
      aspectized_pixel = @w.to_f / (@aspect * 2)
      (pix / aspectized_pixel) - @aspect
    end
    
    def aspectize_y(pix)
      aspectized_pixel = @h.to_f / 2
      (pix / aspectized_pixel) - 1
    end
    
    def residual_with_reset(r)
      "%.10f" % (r/10)
    end
end
