# -*- encoding : utf-8 -*-
# Flips the comp being exported horizontally
class Tracksperanto::Tool::Flip < Tracksperanto::Tool::Base
  
  def self.action_description
    "Mirrors all the tracker paths horizontally"
  end
  
  def start_export(w, h)
    factor = -1
    @exporter = Tracksperanto::Tool::Scaler.new(@exporter, :x_factor => factor)
    super
  end
end
