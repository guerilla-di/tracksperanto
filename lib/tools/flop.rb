# Flips the comp being exported vertically
class Tracksperanto::Tool::Flop < Tracksperanto::Tool::Base
  
  def self.action_description
    "Mirror all the tracker paths vertically"
  end
  
  def start_export(w, h)
    factor = -1
    @exporter = Tracksperanto::Tool::Scaler.new(@exporter, :y_factor => factor)
    super
  end
end
