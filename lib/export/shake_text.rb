class Tracksperanto::Export::Pftrack < Tracksperanto::Export::Base
  PREAMBLE = "TrackName %s\n   Frame             X             Y   Correlation\n"
  POSTAMBLE = "\n\n"
  
  def start_tracker_segment(tracker_name)
    if @any_tracks
      @io.puts POSTAMBLE
    else
      @any_tracks = true
    end
    
    @io.puts PREAMBLE % tracker_name
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    # Shake starts from frame 1, not 0
    line = "%2.f %.3f %.3f %.3f" % [frame + 1, abs_float_x, abs_float_y, 1 - float_residual]
    @io.puts line
  end
end