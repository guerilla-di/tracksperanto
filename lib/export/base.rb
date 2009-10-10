# Base exporter. Inherit from this class to automatically register another export format. 
# The exporters in Tracksperanto are event-driven and follow the same conventions - your
# exporter will be notified when a tracker will be exported and when a tracker has been passed
# (the last keyframe has been sent)
class Tracksperanto::Export::Base
  include Tracksperanto::ConstName
  include Tracksperanto::SimpleExport
  
  attr_reader :io
  
  def self.inherited(by)
    Tracksperanto.exporters << by
    super
  end
  
  # Should return the suffix and extension of this export file (like "flame.stabilizer"), without
  # the leading underscore. It's a class method because it gets requested before the exporter is instantiated
  def self.desc_and_extension
    "data.txt"
  end
  
  # Should return the human-readable (read: properly capitalized and with spaces) name of the export module
  def self.human_name
    "Abstract export format"
  end
  
  # The constructor for an exporter should accept a handle to the IO object that you can write to.
  # This gets assigned to @io ivar by default, but you can do whatever ypu wish
  # By convention, the caller will close the IO when you are done so don't do it here
  def initialize(write_to_io)
    @io = write_to_io
  end
  
  # Called on export start. Will receive the width and height of the comp being exported
  def start_export( img_width, img_height)
  end
  
  # Called on export end. By convention, the caller will close the IO when you are done so don't do it here
  def end_export
  end
  
  # Called on tracker start, once for each tracker. Receives the name of the tracker.
  def start_tracker_segment(tracker_name)
  end
  
  # Called on tracker end
  def end_tracker_segment
  end
  
  # Called for each tracker keyframe, with the Tracksperanto internal coordinates and frame numbers
  def export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
  end
end