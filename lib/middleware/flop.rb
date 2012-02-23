# -*- encoding : utf-8 -*-
# Flips the comp being exported vertically
class Tracksperanto::Middleware::Flop < Tracksperanto::Middleware::Base
  def start_export(w, h)
    factor = -1
    @exporter = Tracksperanto::Middleware::Scaler.new(@exporter, :y_factor => factor)
    super
  end
end
