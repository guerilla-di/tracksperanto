# Multiplexor. Accepts a number of exporters and replays 
# the calls to all of them in succession.
class Tracksperanto::Export::Mux
  def initialize(outputs)
    @outputs = outputs
  end

  %w( start_export start_tracker_segment end_tracker_segment
    export_point end_export).each do | m |
    define_method(m){|*a| @outputs.map{|o| o.public_send(m, *a)}}
  end
end
