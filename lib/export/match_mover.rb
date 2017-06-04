# Export for Autodesk MatchMover/Image Modeler
class Tracksperanto::Export::MatchMover < Tracksperanto::Export::Base
  
  def self.desc_and_extension
    "matchmover.rz2"
  end
  
  def self.human_name
    "MatchMover REALVIZ Ascii Point Tracks .rz2 file"
  end
  
  PREAMBLE = %[imageSequence	"Sequence 01"\n{\n\t%d\t%d\tf( "D:/temp/sequence.%%04d.dpx" )\tb( 1 211 1 )\t\n}\n]
  TRACKER_PREAMBLE = "pointTrack  %s  rgb( 255 0 0 )	\n{\n"
  TRACKER_POSTAMBLE = "}\n"
  FIRST_KEYFRAME_TEMPLATE = "\t%d\t   %.3f     %.3f    ki( 0.8 )\t    s( 66 66 64 64 )  p( 24 24 25 25 )"
  KEYFRAME_TEMPLATE = "\t%d\t   %.3f     %.3f     p+( %.6f )\t"
  
  def start_export( img_width, img_height)
    @height = img_height
    @io.puts(PREAMBLE % [img_width, img_height])
  end
  
  def start_tracker_segment(tracker_name)
    @tracker_name = tracker_name
    @at_first_point = true
    @io.write(TRACKER_PREAMBLE % tracker_name.inspect)
  end
  
  def end_tracker_segment
    @io.write(TRACKER_POSTAMBLE)
  end
  
  def export_point(frame, abs_float_x, abs_float_y, float_residual)
    template = @at_first_point ? FIRST_KEYFRAME_TEMPLATE : KEYFRAME_TEMPLATE
    values = [frame + 1, abs_float_x, @height - abs_float_y, (1 - float_residual)]
    @io.puts(template % values)
    @at_first_point = false
  end
  
end
