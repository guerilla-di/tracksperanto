# For Syntheyes, zero is at the
# optical center of the image, and goes positive right and up. The corners get the [-1..1] coordinates
# respectively. Since Tracksperanto works in absolute pixels we need to convert to and from these cords.
# Note that Syntheyes actually assumes the center of the first pixel to be at -1,1 so a small
# adjustment is necessary to maintain subpixel accuracy.
module Tracksperanto::UVCoordinates
  
  # Convert absolute X and Y values off the BL corner into Syntheyes UV coordinates
  def absolute_to_uv(abs_x, abs_y, w, h)
    [convert_to_uv(abs_x, w), convert_to_uv(abs_y, h) * -1]
  end
  
  # Convert absolute pixel value off the BL corner into Syntheyes UV coordinate
  def convert_to_uv(abs_value, absolute_side)
    uv_value = (((abs_value.to_f - 0.5) / (absolute_side.to_f - 1)) - 0.5) * 2.0
  end

  # Convert Syntheyes UV value into absolute pixel value off the BL corner
  def convert_from_uv(uv_value, absolute_side)
    # Account for the fact that Syntheyes assumes the
    # pixel values to be at the center of the pixel
    abs_value = (((uv_value.to_f / 2.0) + 0.5) * (absolute_side.to_f - 1)) + 0.5
  end
end
