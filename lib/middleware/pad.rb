# This middleware pads the comp or crops it if given negative values. Use it to say unpad
# some fucked-up telecine transfers. The padding is in fractional units of the total width
class Tracksperanto::Middleware::Pad < Tracksperanto::Middleware::Base
  attr_accessor :left_pad, :right_pad, :top_pad, :bottom_pad
  
  cast_to_float :left_pad, :right_pad, :top_pad, :bottom_pad
  
  def start_export(w, h)
    @shift_left, @shift_bottom = w * left_pad, h * bottom_pad
    
    new_w = w + (w * (left_pad + right_pad))
    new_h = h + (h * (bottom_pad + right_pad))
    super(new_w.ceil, new_h.ceil)
  end
  
  def export_point(frame, float_x, float_y, float_residual)
    super(frame, float_x - @shift_left, float_y - @shift_bottom, float_residual)
  end
  
end