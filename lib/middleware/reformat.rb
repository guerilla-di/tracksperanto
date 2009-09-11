require File.dirname(__FILE__) + '/scaler'

# This middleware reformats (scales) the track setup to a specific pixel resolution. Very useful for
# applying proxy tracks to full-res images
class Tracksperanto::Middleware::Reformat < Tracksperanto::Middleware::Scaler
  
  # To which format we have to scale
  attr_accessor :width, :height
  
  private :x_factor=, :y_factor=
  
  # Called on export start
  def start_export( img_width, img_height)
    @width ||= img_width
    @height ||= img_height
    
    self.x_factor, self.y_factor = (@width / img_width.to_f), (@height / img_height.to_f)  
    set_residual_factor
    # Do not call super since it scales by itself :-)
    @exporter.start_export(@width, @height)
  end
end