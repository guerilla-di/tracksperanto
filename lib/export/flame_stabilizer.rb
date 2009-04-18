class Tracksperanto::Export::FlameStabilizer < Tracksperanto::Export::Base
  PREAMBLE = '' #__DATA__.read
  
  # Should return the suffix and extension of this export file (like "_flame.stabilizer")
  def self.desc_and_extension
    "flame.stabilizer"
  end
  
  def start_export(w, h)
    @width = w, @height = h
  end
  
  def start_tracker_segment(tracker_name)
    @tracker_count ||= 0
    @tracker_count += 1
  end
  
  def end_export
    preamble = PREAMBLE % [ @tracker_count, @width, @height]
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
  end
end

__END__
StabilizerFileVersion 5.0
CreationDate Tue Dec  9 21:02:02 2008


NbTrackers %d
Selected 0
FrameWidth %d
FrameHeight %d
AutoKey yes
MotionPath yes
Icons yes
AutoPan no
EditMode 1
Format 0
Padding
	Red 0
	Green 0
	Blue 0
Oversampling no
Opacity 50
Zoom 3
Field no
Backward no
Anim
