require File.dirname(__FILE__) + '/scaler'

# Reformats (scales) the track setup to a specific pixel resolution
class Tracksperanto::Middleware::Reformat < Tracksperanto::Middleware::Scaler
  attr_accessor :width, :height
  
  # Called on export start
  def start_export( img_width, img_height)
    @width ||= img_width
    @height ||= img_height
    
    self.x_factor, self.y_factor = (@width / img_width.to_f), (@height / img_height.to_f)  
    
    super(@width, @height)
  end
end