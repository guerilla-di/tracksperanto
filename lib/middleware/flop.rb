# -*- encoding : utf-8 -*-
# Flips the comp being exported vertically
class Tracksperanto::Middleware::Flop < Tracksperanto::Middleware::Base
  
  def self.action_description
    "Mirror all the tracker paths vertically"
  end
  
  def start_export(w, h)
    factor = -1
    @exporter = Tracksperanto::Middleware::Scaler.new(@exporter, :y_factor => factor)
    super
  end
end
