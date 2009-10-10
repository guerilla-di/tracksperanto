require File.dirname(__FILE__) + '/scaler'

# This middleware reformats (scales) the track setup to a specific pixel resolution. Very useful for
# applying proxy tracks to full-res images
class Tracksperanto::Middleware::Reformat < Tracksperanto::Middleware::Base
  
  # To which format we have to scale
  attr_accessor :width, :height
  cast_to_int :width, :height
  
  # Called on export start
  def start_export( img_width, img_height)
    @width ||= img_width # If they be nil
    @height ||= img_height
    
    x_factor, y_factor = (@width / img_width.to_f), (@height / img_height.to_f)  
    
    @stash = @exporter
    @exporter = Tracksperanto::Middleware::Scaler.new(@exporter, :x_factor => x_factor, :y_factor => y_factor)
    super
  end
  
  def end_export
    @exporter = @stash
  end
end