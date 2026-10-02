# Multiplexor. Accepts a number of exporters and replays 
# the calls to all of them in succession.
class Tracksperanto::Export::Mux
  def initialize(outputs)
    @outputs = outputs
  end

  %w( start_export start_tracker_segment end_tracker_segment
    export_point end_export).each do | m |
    class_eval "def #{m}(*a); @outputs.map{|o| o.#{m}(*a)}; end", __FILE__, __LINE__
  end
end
