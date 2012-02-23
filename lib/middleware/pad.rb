# -*- encoding : utf-8 -*-
# This middleware pads the comp or crops it if given negative values. Use it to say unpad
# some fucked-up telecine transfers. The padding is in fractional units of the total width
# and height
class Tracksperanto::Middleware::Pad < Tracksperanto::Middleware::Base
  attr_accessor :left_pad, :right_pad, :top_pad, :bottom_pad
  
  cast_to_float :left_pad, :right_pad, :top_pad, :bottom_pad
  
  def self.action_description
    "Pad or crop the image by a fraction of it's original size"
  end
  
  def start_export(w, h)
    @shift_left, @shift_bottom = w * left_pad, h * bottom_pad
    w_mult = 1 + left_pad + right_pad
    h_mult = 1 + bottom_pad + top_pad
    super((w * w_mult).ceil, (h * h_mult).ceil)
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame, float_x - @shift_left, float_y - @shift_bottom, float_residual)
  end
  
end
