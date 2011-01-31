# Flips the comp being exported vertically
class Tracksperanto::Middleware::Flop < Tracksperanto::Middleware::Base
  
  attr_accessor :enabled
  
  def start_export(w, h)
    factor = enabled ? -1 : 1
    @exporter = Tracksperanto::Middleware::Scaler.new(@exporter, :y_factor => factor)
    super
  end
end