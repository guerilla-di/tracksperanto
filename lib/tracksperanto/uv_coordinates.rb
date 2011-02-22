# Syntheyes and some other apps use a relative UV coordinate sustem. For Syntheyes, zero is at the
# optical center of the image, and goes positive right and up. Since Tracksperanto works in absolute
# pixels we need to convert to and fro.
module Tracksperanto::UVCoordinates
  
  # UV coords used by Syntheyes and it's lens distortion algos.
  def absolute_to_uv(abs_x, abs_y, w, h)
    [convert_to_uv(abs_x, w), convert_to_uv(abs_y, h) * -1]
  end
  
  def convert_to_uv(absolute_value, absolute_side)
    x = (absolute_value / absolute_side.to_f) - 0.5
    # .2 to -.3, y is reversed and coords are double
    x * 2
  end
  
  def convert_from_uv(absolute_side, uv_value)
    # First, start from zero (-.1 becomes .4)
    value_off_corner = (uv_value.to_f / 2) + 0.5
    absolute_side * value_off_corner
  end
end