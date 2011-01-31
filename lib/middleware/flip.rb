# Flips the comp being exported horizontally
class Tracksperanto::Middleware::Flip < Tracksperanto::Middleware::Base

  attr_accessor :enabled
  
  def start_export(w, h)
    factor = enabled ? -1 : 1
    @exporter = Tracksperanto::Middleware::Scaler.new(@exporter, :x_factor => factor)
    super
  end
end