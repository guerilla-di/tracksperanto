# Base exporter. Inherit from this class to automatically register another export format. 
# The exporters in Tracksperanto are event-driven and follow the same conventions - your
# exporter will be notified when a tracker will be exported and when a tracker has been passed
# (the last keyframe has been sent). Here's how you can operate any exporter module
# separately (this also demonstrates the calling convention and sequence):
#
#     File.open("destination.txt", "wb") do | f |
#       exporter = SomeExporter.new(f)
#       exporter.start_export(720, 576)
#
#       # Export the first tracker
#       exporter.start_tracker_segment("FirstPoint")
#       exporter.export_point(2, 123.43, 456.2, 0.2)
#       exporter.export_point(3, 23423.43, 768.1, 0.1)
#       exporter.end_tracker_segment
#
#       # Export the second tracker
#       exporter.start_tracker_segment("AnotherPoint")
#       ....
#       exported.end_tracker_segment
#       exporter.end_export
#     end
#
# By contract export_point will be called at least once for each tracker being exported (no empty trackers will be sent)
class Tracksperanto::Export::Base
  include Tracksperanto::ConstName, Tracksperanto::SimpleExport
  
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
  # This gets assigned to @io ivar by default, but you can do whatever you wish
  # By convention, the caller owns the IO handle and will close it when you are done, so don't close t yourself
  def initialize(write_to_io)
    @io = write_to_io
  end
  
  # Called on export start. Will receive the width and height of the comp being exported as Integers
  def start_export( img_width, img_height)
  end
  
  # Called on export end. By convention, the caller will close the main IO when you are done so don't do it here.
  # However if you've allocated anything during export (like some Tempfiles) here will be the place to get rid
  # of them
  def end_export
  end
  
  # Called on tracker start, once for each tracker. Receives the name of the tracker.
  def start_tracker_segment(tracker_name)
  end

  # Called for each tracker keyframe, with the Tracksperanto internal coordinates and frame numbers.
  # The calls come after start_tracker_segment and before end_tracker_segment
  def export_point(at_frame_i, abs_float_x, abs_float_y, float_residual)
  end
  
  # Called on tracker end, once for each tracker
  def end_tracker_segment
  end
  
end
